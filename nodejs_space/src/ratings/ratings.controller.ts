import { Controller, Post, Get, Body, Param, Query, UseGuards, Req, ParseIntPipe } from '@nestjs/common';
import type { Request } from 'express';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { PrismaService } from '../prisma/prisma.service';
import { CreateRatingDto, RatingResponseDto, RatingListResponseDto } from './dto/rating.dto';

@Controller('api/merchants')
export class RatingsController {
  constructor(private prisma: PrismaService) {}

  @Post(':id/ratings')
  @UseGuards(JwtAuthGuard)
  async create(@Param('id') merchantId: string, @Body() dto: CreateRatingDto, @Req() req: Request): Promise<RatingResponseDto> {
    const user = req.user as { id: string };
    const rating = await this.prisma.rating.upsert({
      where: { userId_merchantId: { userId: user.id, merchantId } },
      create: { userId: user.id, merchantId, score: dto.score },
      update: { score: dto.score },
    });
    return { id: rating.id, merchantId: rating.merchantId, score: rating.score, createdAt: rating.createdAt.toISOString() };
  }

  @Get(':id/ratings')
  async findAll(
    @Param('id') merchantId: string,
    @Query('page', new ParseIntPipe({ optional: true })) page?: number,
    @Query('limit', new ParseIntPipe({ optional: true })) limit?: number,
  ): Promise<RatingListResponseDto> {
    const p = page ?? 1;
    const l = limit ?? 20;
    const [ratings, agg] = await Promise.all([
      this.prisma.rating.findMany({
        where: { merchantId }, skip: (p - 1) * l, take: l,
        include: { user: { select: { name: true } } },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.rating.aggregate({
        where: { merchantId }, _avg: { score: true }, _count: true,
      }),
    ]);
    return {
      items: ratings.map(r => ({ id: r.id, score: r.score, userName: r.user.name, createdAt: r.createdAt.toISOString() })),
      average: agg._avg?.score ?? 0,
      total: agg._count,
    };
  }
}
