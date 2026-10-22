import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { getFileUrl } from '../lib/s3';
import { CreateProductDto, UpdateProductDto } from './dto/product.dto';
import { Prisma } from '@prisma/client';

@Injectable()
export class ProductsService {
  constructor(private prisma: PrismaService) {}

  private async getMerchantInfo(merchantId: string) {
    const merchant = await this.prisma.merchant.findUnique({
      where: { id: merchantId },
      include: { logoFile: true },
    });
    if (!merchant) return { id: merchantId, shopName: null, averageRating: 0, logoFileId: null, logoUrl: null };

    const rating = await this.prisma.rating.aggregate({
      where: { merchantId }, _avg: { score: true },
    });
    let logoUrl: string | null = null;
    if (merchant.logoFile) {
      logoUrl = await getFileUrl(merchant.logoFile.cloud_storage_path, merchant.logoFile.contentType, merchant.logoFile.isPublic);
    }
    return {
      id: merchant.id, shopName: merchant.shopName,
      averageRating: rating._avg?.score ?? 0,
      logoFileId: merchant.logoFileId, logoUrl,
    };
  }

  private async getImageUrl(file: { cloud_storage_path: string; contentType: string; isPublic: boolean }) {
    return getFileUrl(file.cloud_storage_path, file.contentType, file.isPublic);
  }

  async create(userId: string, dto: CreateProductDto) {
    const merchant = await this.prisma.merchant.findUnique({ where: { userId } });
    if (!merchant || !merchant.setupComplete) throw new ForbiddenException('Merchant setup required');

    const product = await this.prisma.product.create({
      data: {
        merchantId: merchant.id,
        name: dto.name,
        price: dto.price,
        phone: dto.phone,
        description: dto.description ?? null,
        expiryDate: new Date(dto.expiryDate),
        publishDate: dto.publishDate ? new Date(dto.publishDate) : new Date(),
      },
    });

    // Create product images
    for (let i = 0; i < dto.imageFileIds.length; i++) {
      await this.prisma.productImage.create({
        data: {
          productId: product.id,
          fileId: dto.imageFileIds[i],
          isPrimary: i === 0,
          sortOrder: i,
        },
      });
    }

    // Create notifications for followers
    const followers = await this.prisma.merchantFollow.findMany({ where: { merchantId: merchant.id } });
    if (followers.length > 0) {
      await this.prisma.notification.createMany({
        data: followers.map(f => ({
          userId: f.userId,
          type: 'new_product',
          message: `${merchant.shopName ?? 'تاجر'} نشر منتج جديد: ${dto.name}`,
          productId: product.id,
          merchantId: merchant.id,
        })),
      });
    }

    return this.findOne(product.id, userId);
  }

  async update(productId: string, userId: string, dto: UpdateProductDto) {
    const merchant = await this.prisma.merchant.findUnique({ where: { userId } });
    if (!merchant) throw new ForbiddenException('Not a merchant');

    const product = await this.prisma.product.findUnique({ where: { id: productId } });
    if (!product) throw new NotFoundException('Product not found');
    if (product.merchantId !== merchant.id) throw new ForbiddenException('Not your product');

    const data: any = {};
    if (dto.name !== undefined) data.name = dto.name;
    if (dto.price !== undefined) data.price = dto.price;
    if (dto.phone !== undefined) data.phone = dto.phone;
    if (dto.description !== undefined) data.description = dto.description;
    if (dto.expiryDate !== undefined) data.expiryDate = new Date(dto.expiryDate);
    if (dto.publishDate !== undefined) data.publishDate = new Date(dto.publishDate);

    await this.prisma.product.update({ where: { id: productId }, data });

    if (dto.imageFileIds) {
      await this.prisma.productImage.deleteMany({ where: { productId } });
      for (let i = 0; i < dto.imageFileIds.length; i++) {
        await this.prisma.productImage.create({
          data: { productId, fileId: dto.imageFileIds[i], isPrimary: i === 0, sortOrder: i },
        });
      }
    }

    return this.findOne(productId, userId);
  }

  async remove(productId: string, userId: string) {
    const merchant = await this.prisma.merchant.findUnique({ where: { userId } });
    if (!merchant) throw new ForbiddenException('Not a merchant');
    const product = await this.prisma.product.findUnique({ where: { id: productId } });
    if (!product) throw new NotFoundException('Product not found');
    if (product.merchantId !== merchant.id) throw new ForbiddenException('Not your product');
    await this.prisma.product.delete({ where: { id: productId } });
    return { success: true };
  }

  async findOne(id: string, userId?: string | null) {
    const product = await this.prisma.product.findUnique({
      where: { id },
      include: {
        images: { include: { file: true }, orderBy: { sortOrder: 'asc' } },
      },
    });
    if (!product) throw new NotFoundException('Product not found');

    const merchantInfo = await this.getMerchantInfo(product.merchantId);
    const now = new Date();
    const isAvailable = product.expiryDate > now && product.publishDate <= now;

    let isFavorited = false;
    if (userId) {
      const fav = await this.prisma.favorite.findUnique({
        where: { userId_productId: { userId, productId: id } },
      });
      isFavorited = !!fav;
    }

    const images = await Promise.all(product.images.map(async (img) => ({
      id: img.id,
      fileId: img.fileId,
      url: await this.getImageUrl(img.file),
      isPrimary: img.isPrimary,
      sortOrder: img.sortOrder,
    })));

    return {
      id: product.id, name: product.name, price: product.price,
      phone: product.phone, description: product.description,
      expiryDate: product.expiryDate.toISOString(),
      publishDate: product.publishDate.toISOString(),
      viewCount: product.viewCount, isAvailable,
      merchant: merchantInfo, images, isFavorited,
      createdAt: product.createdAt.toISOString(),
    };
  }

  async incrementView(id: string) {
    const product = await this.prisma.product.update({
      where: { id }, data: { viewCount: { increment: 1 } },
    });
    return { viewCount: product.viewCount };
  }

  async findAll(query: {
    governorateId?: string; delegationId?: string; tradeType?: string;
    merchantId?: string; search?: string; available?: string;
    page?: number; limit?: number;
  }, userId?: string | null) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const where: any = {};

    if (query.merchantId) {
      where.merchantId = query.merchantId;
    } else {
      // Filter by merchant's location/trade
      const merchantWhere: any = { setupComplete: true };
      if (query.governorateId) merchantWhere.governorateId = query.governorateId;
      if (query.delegationId) merchantWhere.delegationId = query.delegationId;
      if (query.tradeType) merchantWhere.tradeType = query.tradeType;

      if (query.governorateId || query.delegationId || query.tradeType) {
        where.merchant = merchantWhere;
      }
    }

    if (query.search) {
      where.name = { contains: query.search };
    }

    if (query.available === 'true') {
      const now = new Date();
      where.expiryDate = { gt: now };
      where.publishDate = { lte: now };
    }

    const [items, total] = await Promise.all([
      this.prisma.product.findMany({
        where, skip: (page - 1) * limit, take: limit,
        include: {
          images: { include: { file: true }, orderBy: { sortOrder: 'asc' } },
          merchant: { include: { logoFile: true } },
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.product.count({ where }),
    ]);

    let favSet = new Set<string>();
    if (userId && items.length > 0) {
      const favs = await this.prisma.favorite.findMany({
        where: { userId, productId: { in: items.map(i => i.id) } },
      });
      favSet = new Set(favs.map(f => f.productId));
    }

    const merchantIds = [...new Set(items.map(i => i.merchantId))];
    const ratingGroups = merchantIds.length > 0
      ? await this.prisma.rating.groupBy({
          by: ['merchantId'],
          where: { merchantId: { in: merchantIds } },
          _avg: { score: true },
        })
      : [];
    const ratingMap = new Map(ratingGroups.map(r => [r.merchantId, r._avg?.score ?? 0]));

    const now = new Date();
    const mapped = await Promise.all(items.map(async (p) => {
      let logoUrl: string | null = null;
      if (p.merchant?.logoFile) {
        logoUrl = await this.getImageUrl(p.merchant.logoFile);
      }
      const merchantInfo = {
        id: p.merchant?.id ?? p.merchantId,
        shopName: p.merchant?.shopName ?? null,
        averageRating: ratingMap.get(p.merchantId) ?? 0,
        logoFileId: p.merchant?.logoFileId ?? null,
        logoUrl,
      };
      const primaryImage = p.images.find(i => i.isPrimary) ?? p.images[0];
      let primaryImageUrl: string | null = null;
      if (primaryImage?.file) {
        primaryImageUrl = await this.getImageUrl(primaryImage.file);
      }
      return {
        id: p.id, name: p.name, price: p.price, phone: p.phone,
        description: p.description,
        expiryDate: p.expiryDate.toISOString(),
        publishDate: p.publishDate.toISOString(),
        viewCount: p.viewCount,
        isAvailable: p.expiryDate > now && p.publishDate <= now,
        merchant: merchantInfo,
        primaryImageUrl,
        imageCount: p.images.length,
        isFavorited: favSet.has(p.id),
        createdAt: p.createdAt.toISOString(),
      };
    }));

    return { items: mapped, total, page, totalPages: Math.ceil(total / limit) };
  }

  async findMine(userId: string, page = 1, limit = 20) {
    const merchant = await this.prisma.merchant.findUnique({ where: { userId } });
    if (!merchant) throw new ForbiddenException('Not a merchant');
    return this.findAll({ merchantId: merchant.id, page, limit }, userId);
  }
}
