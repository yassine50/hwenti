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
exports.NotificationsController = void 0;
const openapi = require("@nestjs/swagger");
const common_1 = require("@nestjs/common");
const jwt_auth_guard_1 = require("../auth/jwt-auth.guard");
const prisma_service_1 = require("../prisma/prisma.service");
const s3_1 = require("../lib/s3");
let NotificationsController = class NotificationsController {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async findAll(req, page, limit) {
        const user = req.user;
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
            let merchantLogoUrl = null;
            if (n.merchant?.logoFile) {
                merchantLogoUrl = await (0, s3_1.getFileUrl)(n.merchant.logoFile.cloud_storage_path, n.merchant.logoFile.contentType, n.merchant.logoFile.isPublic);
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
    async markRead(id, req) {
        const user = req.user;
        await this.prisma.notification.updateMany({ where: { id, userId: user.id }, data: { isRead: true } });
        return { success: true };
    }
};
exports.NotificationsController = NotificationsController;
__decorate([
    openapi.ApiQuery({ name: "page", required: false }),
    openapi.ApiQuery({ name: "limit", required: false }),
    (0, common_1.Get)(),
    openapi.ApiResponse({ status: 200, type: require("./dto/notification.dto").NotificationListResponseDto }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Query)('page', new common_1.ParseIntPipe({ optional: true }))),
    __param(2, (0, common_1.Query)('limit', new common_1.ParseIntPipe({ optional: true }))),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Number, Number]),
    __metadata("design:returntype", Promise)
], NotificationsController.prototype, "findAll", null);
__decorate([
    (0, common_1.Patch)(':id/read'),
    openapi.ApiResponse({ status: 200, type: require("./dto/notification.dto").NotificationReadResponseDto }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], NotificationsController.prototype, "markRead", null);
exports.NotificationsController = NotificationsController = __decorate([
    (0, common_1.Controller)('api/notifications'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], NotificationsController);
//# sourceMappingURL=notifications.controller.js.map