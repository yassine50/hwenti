import { Controller, Post, Body, UseGuards, Req } from '@nestjs/common';
import type { Request } from 'express';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { PrismaService } from '../prisma/prisma.service';
import { CreateReportDto, ReportResponseDto } from './dto/report.dto';

@Controller('api/reports')
@UseGuards(JwtAuthGuard)
export class ReportsController {
  constructor(private prisma: PrismaService) {}

  @Post()
  async create(@Body() dto: CreateReportDto, @Req() req: Request): Promise<ReportResponseDto> {
    const user = req.user as { id: string };
    const report = await this.prisma.report.create({
      data: { userId: user.id, merchantId: dto.merchantId, reason: dto.reason, details: dto.details ?? null },
    });
    return { id: report.id, merchantId: report.merchantId, reason: report.reason, createdAt: report.createdAt.toISOString() };
  }
}
