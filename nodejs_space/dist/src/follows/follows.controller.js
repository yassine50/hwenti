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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.FollowsController = void 0;
const openapi = require("@nestjs/swagger");
const common_1 = require("@nestjs/common");
const jwt_auth_guard_1 = require("../auth/jwt-auth.guard");
const prisma_service_1 = require("../prisma/prisma.service");
const merchants_service_1 = require("../merchants/merchants.service");
const s3_1 = require("../lib/s3");
let FollowsController = class FollowsController {
    prisma;
    merchantsService;
    constructor(prisma, merchantsService) {
        this.prisma = prisma;
        this.merchantsService = merchantsService;
    }
    async follow(merchantId, req) {
        const user = req.user;
        await this.prisma.merchantFollow.upsert({
            where: { userId_merchantId: { userId: user.id, merchantId } },
            create: { userId: user.id, merchantId },
            update: {},
        });
        return { success: true };
    }
    async unfollow(merchantId, req) {
        const user = req.user;
        await this.prisma.merchantFollow.deleteMany({ where: { userId: user.id, merchantId } });
        return { success: true };
    }
    async findAll(req, page, limit) {
        const user = req.user;
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
            let logoUrl = null;
            if (f.merchant.logoFile) {
                logoUrl = await (0, s3_1.getFileUrl)(f.merchant.logoFile.cloud_storage_path, f.merchant.logoFile.contentType, f.merchant.logoFile.isPublic);
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
};
exports.FollowsController = FollowsController;
__decorate([
    (0, common_1.Post)(':merchantId'),
    openapi.ApiResponse({ status: 201, type: require("./dto/follow.dto").FollowSuccessDto }),
    __param(0, (0, common_1.Param)('merchantId')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], FollowsController.prototype, "follow", null);
__decorate([
    (0, common_1.Delete)(':merchantId'),
    openapi.ApiResponse({ status: 200, type: require("./dto/follow.dto").FollowSuccessDto }),
    __param(0, (0, common_1.Param)('merchantId')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], FollowsController.prototype, "unfollow", null);
__decorate([
    openapi.ApiQuery({ name: "page", required: false }),
    openapi.ApiQuery({ name: "limit", required: false }),
    (0, common_1.Get)(),
    openapi.ApiResponse({ status: 200, type: require("./dto/follow.dto").FollowListResponseDto }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Query)('page', new common_1.ParseIntPipe({ optional: true }))),
    __param(2, (0, common_1.Query)('limit', new common_1.ParseIntPipe({ optional: true }))),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Number, Number]),
    __metadata("design:returntype", Promise)
], FollowsController.prototype, "findAll", null);
exports.FollowsController = FollowsController = __decorate([
    (0, common_1.Controller)('api/follows'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService, merchants_service_1.MerchantsService])
], FollowsController);
//# sourceMappingURL=follows.controller.js.map