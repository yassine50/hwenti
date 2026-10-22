"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.MerchantsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const s3_1 = require("../lib/s3");
let MerchantsService = class MerchantsService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async getLogoUrl(merchant) {
        if (!merchant.logoFileId || !merchant.logoFile)
            return null;
        return (0, s3_1.getFileUrl)(merchant.logoFile.cloud_storage_path, merchant.logoFile.contentType, merchant.logoFile.isPublic);
    }
    async getRatingStats(merchantId) {
        const result = await this.prisma.rating.aggregate({
            where: { merchantId },
            _avg: { score: true },
            _count: true,
        });
        return { averageRating: result._avg?.score ?? 0, ratingCount: result._count };
    }
    async setup(userId, dto) {
        const merchant = await this.prisma.merchant.findUnique({ where: { userId } });
        if (!merchant)
            throw new common_1.ForbiddenException('Not a merchant');
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
    async updateMe(userId, dto) {
        const merchant = await this.prisma.merchant.findUnique({ where: { userId } });
        if (!merchant)
            throw new common_1.ForbiddenException('Not a merchant');
        const data = {};
        if (dto.shopName !== undefined)
            data.shopName = dto.shopName;
        if (dto.tradeType !== undefined)
            data.tradeType = dto.tradeType;
        if (dto.governorateId !== undefined)
            data.governorateId = dto.governorateId;
        if (dto.delegationId !== undefined)
            data.delegationId = dto.delegationId;
        if (dto.phone !== undefined)
            data.phone = dto.phone;
        if (dto.logoFileId !== undefined)
            data.logoFileId = dto.logoFileId;
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
    async findMe(userId) {
        const merchant = await this.prisma.merchant.findUnique({
            where: { userId },
            include: { governorate: true, delegation: true, logoFile: true },
        });
        if (!merchant)
            throw new common_1.NotFoundException('Merchant not found');
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
    async findOne(id) {
        const merchant = await this.prisma.merchant.findUnique({
            where: { id },
            include: { governorate: true, delegation: true, logoFile: true },
        });
        if (!merchant)
            throw new common_1.NotFoundException('Merchant not found');
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
    async findAll(query) {
        const page = query.page ?? 1;
        const limit = query.limit ?? 20;
        const where = { setupComplete: true };
        if (query.governorateId)
            where.governorateId = query.governorateId;
        if (query.delegationId)
            where.delegationId = query.delegationId;
        if (query.tradeType)
            where.tradeType = query.tradeType;
        if (query.search)
            where.shopName = { contains: query.search };
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
        const ratingMap = new Map(ratingGroups.map((r) => [
            r.merchantId,
            { averageRating: r._avg?.score ?? 0, ratingCount: r._count },
        ]));
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
};
exports.MerchantsService = MerchantsService;
exports.MerchantsService = MerchantsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], MerchantsService);
//# sourceMappingURL=merchants.service.js.map