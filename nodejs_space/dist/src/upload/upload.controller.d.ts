import type { Request, Response } from 'express';
import { PrismaService } from '../prisma/prisma.service';
import { PresignedUploadDto, CompleteUploadDto, PresignedUploadResponseDto, CompleteUploadResponseDto, FileUrlResponseDto, DeleteFileResponseDto } from './dto/upload.dto';
export declare class UploadController {
    private prisma;
    constructor(prisma: PrismaService);
    presigned(dto: PresignedUploadDto): Promise<PresignedUploadResponseDto>;
    uploadLocal(fileName: string, req: Request): Promise<{
        ok: boolean;
    }>;
    serveLocal(fileName: string, res: Response): Promise<void>;
    complete(dto: CompleteUploadDto, req: Request): Promise<CompleteUploadResponseDto>;
    getUrl(id: string, mode?: string): Promise<FileUrlResponseDto>;
    deleteFileRecord(id: string, req: Request): Promise<DeleteFileResponseDto>;
}
