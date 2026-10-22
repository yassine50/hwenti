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
exports.RatingsController = void 0;
const openapi = require("@nestjs/swagger");
const common_1 = require("@nestjs/common");
const jwt_auth_guard_1 = require("../auth/jwt-auth.guard");
const prisma_service_1 = require("../prisma/prisma.service");
const rating_dto_1 = require("./dto/rating.dto");
let RatingsController = class RatingsController {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async create(merchantId, dto, req) {
        const user = req.user;
        const rating = await this.prisma.rating.upsert({
            where: { userId_merchantId: { userId: user.id, merchantId } },
            create: { userId: user.id, merchantId, score: dto.score },
            update: { score: dto.score },
        });
        return { id: rating.id, merchantId: rating.merchantId, score: rating.score, createdAt: rating.createdAt.toISOString() };
    }
    async findAll(merchantId, page, limit) {
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
};
exports.RatingsController = RatingsController;
__decorate([
    (0, common_1.Post)(':id/ratings'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    openapi.ApiResponse({ status: 201, type: require("./dto/rating.dto").RatingResponseDto }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, rating_dto_1.CreateRatingDto, Object]),
    __metadata("design:returntype", Promise)
], RatingsController.prototype, "create", null);
__decorate([
    openapi.ApiQuery({ name: "page", required: false }),
    openapi.ApiQuery({ name: "limit", required: false }),
    (0, common_1.Get)(':id/ratings'),
    openapi.ApiResponse({ status: 200, type: require("./dto/rating.dto").RatingListResponseDto }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Query)('page', new common_1.ParseIntPipe({ optional: true }))),
    __param(2, (0, common_1.Query)('limit', new common_1.ParseIntPipe({ optional: true }))),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Number, Number]),
    __metadata("design:returntype", Promise)
], RatingsController.prototype, "findAll", null);
exports.RatingsController = RatingsController = __decorate([
    (0, common_1.Controller)('api/merchants'),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], RatingsController);
//# sourceMappingURL=ratings.controller.js.map