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
exports.FavoritesController = void 0;
const openapi = require("@nestjs/swagger");
const common_1 = require("@nestjs/common");
const jwt_auth_guard_1 = require("../auth/jwt-auth.guard");
const prisma_service_1 = require("../prisma/prisma.service");
const products_service_1 = require("../products/products.service");
let FavoritesController = class FavoritesController {
    prisma;
    productsService;
    constructor(prisma, productsService) {
        this.prisma = prisma;
        this.productsService = productsService;
    }
    async add(productId, req) {
        const user = req.user;
        await this.prisma.favorite.upsert({
            where: { userId_productId: { userId: user.id, productId } },
            create: { userId: user.id, productId },
            update: {},
        });
        return { success: true };
    }
    async remove(productId, req) {
        const user = req.user;
        await this.prisma.favorite.deleteMany({ where: { userId: user.id, productId } });
        return { success: true };
    }
    async findAll(req, page, limit) {
        const user = req.user;
        const p = page ?? 1;
        const l = limit ?? 20;
        const [favs, total] = await Promise.all([
            this.prisma.favorite.findMany({
                where: { userId: user.id }, skip: (p - 1) * l, take: l,
                orderBy: { createdAt: 'desc' },
            }),
            this.prisma.favorite.count({ where: { userId: user.id } }),
        ]);
        const results = await Promise.all(favs.map(async (fav) => {
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
            }
            catch {
                return null;
            }
        }));
        const items = results.filter((item) => item !== null);
        return { items, total, page: p, totalPages: Math.ceil(total / l) };
    }
};
exports.FavoritesController = FavoritesController;
__decorate([
    (0, common_1.Post)(':productId'),
    openapi.ApiResponse({ status: 201, type: require("./dto/favorite.dto").FavoriteSuccessDto }),
    __param(0, (0, common_1.Param)('productId')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], FavoritesController.prototype, "add", null);
__decorate([
    (0, common_1.Delete)(':productId'),
    openapi.ApiResponse({ status: 200, type: require("./dto/favorite.dto").FavoriteSuccessDto }),
    __param(0, (0, common_1.Param)('productId')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], FavoritesController.prototype, "remove", null);
__decorate([
    openapi.ApiQuery({ name: "page", required: false }),
    openapi.ApiQuery({ name: "limit", required: false }),
    (0, common_1.Get)(),
    openapi.ApiResponse({ status: 200, type: require("./dto/favorite.dto").FavoriteListResponseDto }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Query)('page', new common_1.ParseIntPipe({ optional: true }))),
    __param(2, (0, common_1.Query)('limit', new common_1.ParseIntPipe({ optional: true }))),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Number, Number]),
    __metadata("design:returntype", Promise)
], FavoritesController.prototype, "findAll", null);
exports.FavoritesController = FavoritesController = __decorate([
    (0, common_1.Controller)('api/favorites'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService, products_service_1.ProductsService])
], FavoritesController);
//# sourceMappingURL=favorites.controller.js.map