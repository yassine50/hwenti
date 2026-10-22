import { Controller, Get, Patch, Param, Query, UseGuards, Req, ParseIntPipe } from '@nestjs/common';
import type { Request } from 'express';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { PrismaService } from '../prisma/prisma.service';
import { NotificationListResponseDto, NotificationReadResponseDto } from './dto/notification.dto';
import { getFileUrl } from '../lib/s3';

@Controller('api/notifications')
@UseGuards(JwtAuthGuard)
export class NotificationsController {
  constructor(private prisma: PrismaService) {}

  @Get()
  async findAll(
    @Req() req: Request,
    @Query('page', new ParseIntPipe({ optional: true })) page?: number,
    @Query('limit', new ParseIntPipe({ optional: true })) limit?: number,
  ): Promise<NotificationListResponseDto> {
    const user = req.user as { id: string };
    const p = page ?? 1;
    const l = limit ?? 20;
    const [notifs, total] = await Promise.all([
      this.prisma.notification.findMany({
        where: { userId: user.id }, skip: (p - 1) * l, take: l,
        include: { merchant: { include: { logoFile: true } } },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.notification.count({ where: { userId: user.id } }),
    ]);

    const items = await Promise.all(notifs.map(async (n) => {
      let merchantLogoUrl: string | null = null;
      if (n.merchant?.logoFile) {
        merchantLogoUrl = await getFileUrl(n.merchant.logoFile.cloud_storage_path, n.merchant.logoFile.contentType, n.merchant.logoFile.isPublic);
      }
      return {
        id: n.id, type: n.type, message: n.message,
        productId: n.productId, merchantId: n.merchantId,
        merchantName: n.merchant?.shopName ?? null,
        merchantLogoUrl, isRead: n.isRead,
        createdAt: n.createdAt.toISOString(),
      };
    }));

    return { items, total, page: p, totalPages: Math.ceil(total / l) };
  }

  @Patch(':id/read')
  async markRead(@Param('id') id: string, @Req() req: Request): Promise<NotificationReadResponseDto> {
    const user = req.user as { id: string };
    await this.prisma.notification.updateMany({ where: { id, userId: user.id }, data: { isRead: true } });
    return { success: true };
  }
}
