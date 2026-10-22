import { Controller, Post, Put, Get, Delete, Body, Param, Query, UseGuards, Req, Res, ForbiddenException, NotFoundException } from '@nestjs/common';
import type { Request, Response } from 'express';
import * as fs from 'fs';
import * as path from 'path';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { PrismaService } from '../prisma/prisma.service';
import { generatePresignedUploadUrl, getFileUrl, deleteFile } from '../lib/s3';
import {
  PresignedUploadDto, CompleteUploadDto,
  PresignedUploadResponseDto, CompleteUploadResponseDto,
  FileUrlResponseDto, DeleteFileResponseDto,
} from './dto/upload.dto';

@Controller('api')
export class UploadController {
  constructor(private prisma: PrismaService) {}

  @Post('upload/presigned')
  @UseGuards(JwtAuthGuard)
  async presigned(@Body() dto: PresignedUploadDto): Promise<PresignedUploadResponseDto> {
    const { uploadUrl, cloud_storage_path } = await generatePresignedUploadUrl(
      dto.fileName, dto.contentType, dto.isPublic ?? true,
    );
    return { uploadUrl, cloud_storage_path };
  }

  @Put('upload/local/:fileName')
  async uploadLocal(@Param('fileName') fileName: string, @Req() req: Request): Promise<{ ok: boolean }> {
    const uploadDir = path.join(process.cwd(), 'uploads');
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    const safeName = path.basename(fileName);
    const targetPath = path.join(uploadDir, safeName);
    const chunks: Buffer[] = [];
    for await (const chunk of req) {
      chunks.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk));
    }
    fs.writeFileSync(targetPath, Buffer.concat(chunks));
    return { ok: true };
  }

  @Get('uploads/:fileName')
  async serveLocal(@Param('fileName') fileName: string, @Res() res: Response) {
    const safeName = path.basename(fileName);
    const targetPath = path.join(process.cwd(), 'uploads', safeName);
    if (!fs.existsSync(targetPath)) {
      throw new NotFoundException('File not found');
    }
    return res.sendFile(targetPath);
  }

  @Post('upload/complete')
  @UseGuards(JwtAuthGuard)
  async complete(@Body() dto: CompleteUploadDto, @Req() req: Request): Promise<CompleteUploadResponseDto> {
    const user = req.user as { id: string };
    const file = await this.prisma.file.create({
      data: {
        userId: user.id,
        fileName: dto.fileName,
        cloud_storage_path: dto.cloud_storage_path,
        isPublic: dto.cloud_storage_path.includes('/public/'),
        contentType: dto.contentType,
        fileSize: dto.fileSize ?? null,
      },
    });
    return { id: file.id, cloud_storage_path: file.cloud_storage_path, fileName: file.fileName };
  }

  @Get('files/:id/url')
  @UseGuards(JwtAuthGuard)
  async getUrl(@Param('id') id: string, @Query('mode') mode?: string): Promise<FileUrlResponseDto> {
    const file = await this.prisma.file.findUnique({ where: { id } });
    if (!file) throw new NotFoundException('File not found');
    const url = await getFileUrl(file.cloud_storage_path, file.contentType, file.isPublic);
    return { url };
  }

  @Delete('files/:id')
  @UseGuards(JwtAuthGuard)
  async deleteFileRecord(@Param('id') id: string, @Req() req: Request): Promise<DeleteFileResponseDto> {
    const user = req.user as { id: string };
    const file = await this.prisma.file.findUnique({ where: { id } });
    if (!file) throw new NotFoundException('File not found');
    if (file.userId !== user.id) throw new ForbiddenException('Unauthorized');
    await deleteFile(file.cloud_storage_path);
    await this.prisma.file.delete({ where: { id } });
    return { success: true };
  }
}
