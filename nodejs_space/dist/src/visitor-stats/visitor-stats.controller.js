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
exports.VisitorStatsController = void 0;
const openapi = require("@nestjs/swagger");
const common_1 = require("@nestjs/common");
const jwt_auth_guard_1 = require("../auth/jwt-auth.guard");
const prisma_service_1 = require("../prisma/prisma.service");
const visitor_stats_dto_1 = require("./dto/visitor-stats.dto");
let VisitorStatsController = class VisitorStatsController {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async track(dto) {
        await this.prisma.visitorStat.create({
            data: {
                governorateId: dto.governorateId ?? null,
                delegationId: dto.delegationId ?? null,
                latitude: dto.latitude ?? null,
                longitude: dto.longitude ?? null,
            },
        });
        return { success: true };
    }
    async summary() {
        const totalVisitors = await this.prisma.visitorStat.count();
        const byGov = await this.prisma.visitorStat.groupBy({
            by: ['governorateId'],
            where: { governorateId: { not: null } },
            _count: true,
            orderBy: { _count: { governorateId: 'desc' } },
        });
        const govIds = byGov.map(g => g.governorateId).filter(Boolean);
        const govs = await this.prisma.governorate.findMany({ where: { id: { in: govIds } } });
        const govMap = new Map(govs.map(g => [g.id, g]));
        const byDel = await this.prisma.visitorStat.groupBy({
            by: ['delegationId', 'governorateId'],
            where: { delegationId: { not: null } },
            _count: true,
            orderBy: { _count: { delegationId: 'desc' } },
        });
        const delIds = byDel.map(d => d.delegationId).filter(Boolean);
        const dels = await this.prisma.delegation.findMany({ where: { id: { in: delIds } } });
        const delMap = new Map(dels.map(d => [d.id, d]));
        return {
            totalVisitors,
            byGovernorate: byGov.map(g => {
                const gov = govMap.get(g.governorateId);
                return {
                    governorateId: g.governorateId,
                    governorateName: gov?.nameAr ?? '',
                    governorateNameAr: gov?.nameAr ?? '',
                    governorateNameFr: gov?.nameFr ?? '',
                    count: g._count,
                };
            }),
            byDelegation: byDel.map(d => {
                const del = delMap.get(d.delegationId);
                return {
                    delegationId: d.delegationId,
                    delegationName: del?.nameAr ?? '',
                    delegationNameAr: del?.nameAr ?? '',
                    delegationNameFr: del?.nameFr ?? '',
                    governorateId: d.governorateId,
                    count: d._count,
                };
            }),
        };
    }
};
exports.VisitorStatsController = VisitorStatsController;
__decorate([
    (0, common_1.Post)('track'),
    openapi.ApiResponse({ status: 201, type: require("./dto/visitor-stats.dto").TrackVisitorResponseDto }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [visitor_stats_dto_1.TrackVisitorDto]),
    __metadata("design:returntype", Promise)
], VisitorStatsController.prototype, "track", null);
__decorate([
    (0, common_1.Get)('summary'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    openapi.ApiResponse({ status: 200, type: require("./dto/visitor-stats.dto").VisitorStatsSummaryResponseDto }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], VisitorStatsController.prototype, "summary", null);
exports.VisitorStatsController = VisitorStatsController = __decorate([
    (0, common_1.Controller)('api/visitor-stats'),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], VisitorStatsController);
//# sourceMappingURL=visitor-stats.controller.js.map