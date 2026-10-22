import type { Request } from 'express';
import { PrismaService } from '../prisma/prisma.service';
import { MerchantsService } from '../merchants/merchants.service';
import { FollowSuccessDto, FollowListResponseDto } from './dto/follow.dto';
export declare class FollowsController {
    private prisma;
    private merchantsService;
    constructor(prisma: PrismaService, merchantsService: MerchantsService);
    follow(merchantId: string, req: Request): Promise<FollowSuccessDto>;
    unfollow(merchantId: string, req: Request): Promise<FollowSuccessDto>;
    findAll(req: Request, page?: number, limit?: number): Promise<FollowListResponseDto>;
}
