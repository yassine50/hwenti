import type { Request } from 'express';
import { PrismaService } from '../prisma/prisma.service';
import { CreateRatingDto, RatingResponseDto, RatingListResponseDto } from './dto/rating.dto';
export declare class RatingsController {
    private prisma;
    constructor(prisma: PrismaService);
    create(merchantId: string, dto: CreateRatingDto, req: Request): Promise<RatingResponseDto>;
    findAll(merchantId: string, page?: number, limit?: number): Promise<RatingListResponseDto>;
}
