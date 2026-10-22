import type { Request } from 'express';
import { PrismaService } from '../prisma/prisma.service';
import { CreateReportDto, ReportResponseDto } from './dto/report.dto';
export declare class ReportsController {
    private prisma;
    constructor(prisma: PrismaService);
    create(dto: CreateReportDto, req: Request): Promise<ReportResponseDto>;
}
