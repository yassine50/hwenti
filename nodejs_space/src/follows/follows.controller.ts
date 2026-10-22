import { Controller, Post, Delete, Get, Param, Query, UseGuards, Req, ParseIntPipe } from '@nestjs/common';
import type { Request } from 'express';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { PrismaService } from '../prisma/prisma.service';
import { MerchantsService } from '../merchants/merchants.service';
import { getFileUrl } from '../lib/s3';
import { FollowSuccessDto, FollowListResponseDto } from './dto/follow.dto';

@Controller('api/follows')
@UseGuards(JwtAuthGuard)
export class FollowsController {
  constructor(private prisma: PrismaService, private merchantsService: MerchantsService) {}

  @Post(':merchantId')
  async follow(@Param('merchantId') merchantId: string, @Req() req: Request): Promise<FollowSuccessDto> {
    const user = req.user as { id: string };
    await this.prisma.merchantFollow.upsert({
      where: { userId_merchantId: { userId: user.id, merchantId } },
      create: { userId: user.id, merchantId },
      update: {},
    });
    return { success: true };
  }

  @Delete(':merchantId')
  async unfollow(@Param('merchantId') merchantId: string, @Req() req: Request): Promise<FollowSuccessDto> {
    const user = req.user as { id: string };
    await this.prisma.merchantFollow.deleteMany({ where: { userId: user.id, merchantId } });
    return { success: true };
  }

  @Get()
  async findAll(
    @Req() req: Request,
    @Query('page', new ParseIntPipe({ optional: true })) page?: number,
    @Query('limit', new ParseIntPipe({ optional: true })) limit?: number,
  ): Promise<FollowListResponseDto> {
    const user = req.user as { id: string };
    const p = page ?? 1;
    const l = limit ?? 20;
    const [follows, total] = await Promise.all([
      this.prisma.merchantFollow.findMany({
        where: { userId: user.id }, skip: (p - 1) * l, take: l,
        include: { merchant: { include: { governorate: true, logoFile: true } } },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.merchantFollow.count({ where: { userId: user.id } }),
    ]);

    const items = await Promise.all(follows.map(async (f) => {
      let logoUrl: string | null = null;
      if (f.merchant.logoFile) {
        logoUrl = await getFileUrl(f.merchant.logoFile.cloud_storage_path, f.merchant.logoFile.contentType, f.merchant.logoFile.isPublic);
      }
      return {
        id: f.id,
        merchant: {
          id: f.merchant.id,
          shopName: f.merchant.shopName,
          tradeType: f.merchant.tradeType,
          governorateName: f.merchant.governorate?.nameAr ?? null,
          governorateNameAr: f.merchant.governorate?.nameAr ?? null,
          governorateNameFr: f.merchant.governorate?.nameFr ?? null,
          logoFileId: f.merchant.logoFileId,
          logoUrl,
        },
        createdAt: f.createdAt.toISOString(),
      };
    }));

    return { items, total, page: p, totalPages: Math.ceil(total / l) };
  }
}
