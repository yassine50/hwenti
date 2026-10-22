import { Controller, Post, Delete, Get, Param, Query, UseGuards, Req, ParseIntPipe } from '@nestjs/common';
import type { Request } from 'express';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { PrismaService } from '../prisma/prisma.service';
import { ProductsService } from '../products/products.service';
import { FavoriteSuccessDto, FavoriteListResponseDto } from './dto/favorite.dto';

@Controller('api/favorites')
@UseGuards(JwtAuthGuard)
export class FavoritesController {
  constructor(private prisma: PrismaService, private productsService: ProductsService) {}

  @Post(':productId')
  async add(@Param('productId') productId: string, @Req() req: Request): Promise<FavoriteSuccessDto> {
    const user = req.user as { id: string };
    await this.prisma.favorite.upsert({
      where: { userId_productId: { userId: user.id, productId } },
      create: { userId: user.id, productId },
      update: {},
    });
    return { success: true };
  }

  @Delete(':productId')
  async remove(@Param('productId') productId: string, @Req() req: Request): Promise<FavoriteSuccessDto> {
    const user = req.user as { id: string };
    await this.prisma.favorite.deleteMany({ where: { userId: user.id, productId } });
    return { success: true };
  }

  @Get()
  async findAll(
    @Req() req: Request,
    @Query('page', new ParseIntPipe({ optional: true })) page?: number,
    @Query('limit', new ParseIntPipe({ optional: true })) limit?: number,
  ): Promise<FavoriteListResponseDto> {
    const user = req.user as { id: string };
    const p = page ?? 1;
    const l = limit ?? 20;
    const [favs, total] = await Promise.all([
      this.prisma.favorite.findMany({
        where: { userId: user.id }, skip: (p - 1) * l, take: l,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.favorite.count({ where: { userId: user.id } }),
    ]);
    // Get product details for each favorite in parallel
    const results = await Promise.all(
      favs.map(async (fav) => {
        try {
          const product = await this.productsService.findOne(fav.productId, user.id);
          return {
            id: product.id, name: product.name, price: product.price, phone: product.phone,
            description: product.description, expiryDate: product.expiryDate,
            publishDate: product.publishDate, viewCount: product.viewCount,
            isAvailable: product.isAvailable, merchant: product.merchant,
            primaryImageUrl: product.images?.[0]?.url ?? null,
            imageCount: product.images?.length ?? 0,
            isFavorited: true, createdAt: product.createdAt,
          };
        } catch {
          // Product may have been deleted
          return null;
        }
      }),
    );
    const items = results.filter((item): item is NonNullable<typeof item> => item !== null);
    return { items, total, page: p, totalPages: Math.ceil(total / l) };
  }
}
