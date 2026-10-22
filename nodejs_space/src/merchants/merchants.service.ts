import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { getFileUrl } from '../lib/s3';
import { MerchantSetupDto, MerchantUpdateDto } from './dto/merchant.dto';

@Injectable()
export class MerchantsService {
  constructor(private prisma: PrismaService) {}

  async getLogoUrl(merchant: { logoFileId: string | null; logoFile?: { cloud_storage_path: string; contentType: string; isPublic: boolean } | null }) {
    if (!merchant.logoFileId || !merchant.logoFile) return null;
    return getFileUrl(merchant.logoFile.cloud_storage_path, merchant.logoFile.contentType, merchant.logoFile.isPublic);
  }

  async getRatingStats(merchantId: string) {
    const result = await this.prisma.rating.aggregate({
      where: { merchantId },
      _avg: { score: true },
      _count: true,
    });
    return { averageRating: result._avg?.score ?? 0, ratingCount: result._count };
  }

  async setup(userId: string, dto: MerchantSetupDto) {
    const merchant = await this.prisma.merchant.findUnique({ where: { userId } });
    if (!merchant) throw new ForbiddenException('Not a merchant');

    const updated = await this.prisma.merchant.update({
      where: { userId },
      data: {
        shopName: dto.shopName,
        tradeType: dto.tradeType,
        governorateId: dto.governorateId,
        delegationId: dto.delegationId,
        phone: dto.phone,
        logoFileId: dto.logoFileId ?? null,
        setupComplete: true,
      },
      include: { governorate: true, delegation: true, logoFile: true },
    });

    const { averageRating, ratingCount } = await this.getRatingStats(updated.id);
    const logoUrl = await this.getLogoUrl(updated);

    return {
      id: updated.id, userId: updated.userId,
      shopName: updated.shopName, tradeType: updated.tradeType,
      governorateId: updated.governorateId,
      governorateName: updated.governorate?.nameAr ?? null,
      governorateNameAr: updated.governorate?.nameAr ?? null,
      governorateNameFr: updated.governorate?.nameFr ?? null,
      delegationId: updated.delegationId,
      delegationName: updated.delegation?.nameAr ?? null,
      delegationNameAr: updated.delegation?.nameAr ?? null,
      delegationNameFr: updated.delegation?.nameFr ?? null,
      phone: updated.phone, logoFileId: updated.logoFileId, logoUrl,
      averageRating, ratingCount, setupComplete: updated.setupComplete,
      createdAt: updated.createdAt.toISOString(),
    };
  }

  async updateMe(userId: string, dto: MerchantUpdateDto) {
    const merchant = await this.prisma.merchant.findUnique({ where: { userId } });
    if (!merchant) throw new ForbiddenException('Not a merchant');

    const data: any = {};
    if (dto.shopName !== undefined) data.shopName = dto.shopName;
    if (dto.tradeType !== undefined) data.tradeType = dto.tradeType;
    if (dto.governorateId !== undefined) data.governorateId = dto.governorateId;
    if (dto.delegationId !== undefined) data.delegationId = dto.delegationId;
    if (dto.phone !== undefined) data.phone = dto.phone;
    if (dto.logoFileId !== undefined) data.logoFileId = dto.logoFileId;

    const updated = await this.prisma.merchant.update({
      where: { userId },
      data,
      include: { governorate: true, delegation: true, logoFile: true },
    });

    const { averageRating, ratingCount } = await this.getRatingStats(updated.id);
    const logoUrl = await this.getLogoUrl(updated);

    return {
      id: updated.id, userId: updated.userId,
      shopName: updated.shopName, tradeType: updated.tradeType,
      governorateId: updated.governorateId,
      governorateName: updated.governorate?.nameAr ?? null,
      governorateNameAr: updated.governorate?.nameAr ?? null,
      governorateNameFr: updated.governorate?.nameFr ?? null,
      delegationId: updated.delegationId,
      delegationName: updated.delegation?.nameAr ?? null,
      delegationNameAr: updated.delegation?.nameAr ?? null,
      delegationNameFr: updated.delegation?.nameFr ?? null,
      phone: updated.phone, logoFileId: updated.logoFileId, logoUrl,
      averageRating, ratingCount, setupComplete: updated.setupComplete,
      createdAt: updated.createdAt.toISOString(),
    };
  }

  async findMe(userId: string) {
    const merchant = await this.prisma.merchant.findUnique({
      where: { userId },
      include: { governorate: true, delegation: true, logoFile: true },
    });
    if (!merchant) throw new NotFoundException('Merchant not found');

    const { averageRating, ratingCount } = await this.getRatingStats(merchant.id);
    const logoUrl = await this.getLogoUrl(merchant);

    return {
      id: merchant.id, userId: merchant.userId,
      shopName: merchant.shopName, tradeType: merchant.tradeType,
      governorateId: merchant.governorateId,
      governorateName: merchant.governorate?.nameAr ?? null,
      governorateNameAr: merchant.governorate?.nameAr ?? null,
      governorateNameFr: merchant.governorate?.nameFr ?? null,
      delegationId: merchant.delegationId,
      delegationName: merchant.delegation?.nameAr ?? null,
      delegationNameAr: merchant.delegation?.nameAr ?? null,
      delegationNameFr: merchant.delegation?.nameFr ?? null,
      phone: merchant.phone, logoFileId: merchant.logoFileId, logoUrl,
      averageRating, ratingCount, setupComplete: merchant.setupComplete,
      createdAt: merchant.createdAt.toISOString(),
    };
  }

  async findOne(id: string) {
    const merchant = await this.prisma.merchant.findUnique({
      where: { id },
      include: { governorate: true, delegation: true, logoFile: true },
    });
    if (!merchant) throw new NotFoundException('Merchant not found');

    const { averageRating, ratingCount } = await this.getRatingStats(merchant.id);
    const logoUrl = await this.getLogoUrl(merchant);

    return {
      id: merchant.id, userId: merchant.userId,
      shopName: merchant.shopName, tradeType: merchant.tradeType,
      governorateId: merchant.governorateId,
      governorateName: merchant.governorate?.nameAr ?? null,
      governorateNameAr: merchant.governorate?.nameAr ?? null,
      governorateNameFr: merchant.governorate?.nameFr ?? null,
      delegationId: merchant.delegationId,
      delegationName: merchant.delegation?.nameAr ?? null,
      delegationNameAr: merchant.delegation?.nameAr ?? null,
      delegationNameFr: merchant.delegation?.nameFr ?? null,
      phone: merchant.phone, logoFileId: merchant.logoFileId, logoUrl,
      averageRating, ratingCount, setupComplete: merchant.setupComplete,
      createdAt: merchant.createdAt.toISOString(),
    };
  }

  async findAll(query: { governorateId?: string; delegationId?: string; tradeType?: string; search?: string; page?: number; limit?: number }) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const where: any = { setupComplete: true };
    if (query.governorateId) where.governorateId = query.governorateId;
    if (query.delegationId) where.delegationId = query.delegationId;
    if (query.tradeType) where.tradeType = query.tradeType;
    if (query.search) where.shopName = { contains: query.search };

    const [items, total] = await Promise.all([
      this.prisma.merchant.findMany({
        where, skip: (page - 1) * limit, take: limit,
        include: { governorate: true, delegation: true, logoFile: true },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.merchant.count({ where }),
    ]);

    const merchantIds = items.map((m) => m.id);
    const ratingGroups = merchantIds.length > 0
      ? await this.prisma.rating.groupBy({
          by: ['merchantId'],
          where: { merchantId: { in: merchantIds } },
          _avg: { score: true },
          _count: true,
        })
      : [];
    const ratingMap = new Map(
      ratingGroups.map((r) => [
        r.merchantId,
        { averageRating: r._avg?.score ?? 0, ratingCount: r._count },
      ]),
    );

    const mapped = await Promise.all(items.map(async (m) => {
      const { averageRating, ratingCount } = ratingMap.get(m.id) ?? { averageRating: 0, ratingCount: 0 };
      const logoUrl = await this.getLogoUrl(m);
      return {
        id: m.id, userId: m.userId, shopName: m.shopName, tradeType: m.tradeType,
        governorateName: m.governorate?.nameAr ?? null,
        governorateNameAr: m.governorate?.nameAr ?? null,
        governorateNameFr: m.governorate?.nameFr ?? null,
        delegationName: m.delegation?.nameAr ?? null,
        delegationNameAr: m.delegation?.nameAr ?? null,
        delegationNameFr: m.delegation?.nameFr ?? null,
        logoFileId: m.logoFileId, logoUrl, averageRating, ratingCount,
      };
    }));

    return { items: mapped, total, page, totalPages: Math.ceil(total / limit) };
  }
}
