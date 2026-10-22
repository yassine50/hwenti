import { PrismaService } from '../prisma/prisma.service';
import { TrackVisitorDto, TrackVisitorResponseDto, VisitorStatsSummaryResponseDto } from './dto/visitor-stats.dto';
export declare class VisitorStatsController {
    private prisma;
    constructor(prisma: PrismaService);
    track(dto: TrackVisitorDto): Promise<TrackVisitorResponseDto>;
    summary(): Promise<VisitorStatsSummaryResponseDto>;
}
