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
exports.GeolocationController = void 0;
const openapi = require("@nestjs/swagger");
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const geolocation_dto_1 = require("./dto/geolocation.dto");
let GeolocationController = class GeolocationController {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async findNearest(dto) {
        const govs = await this.prisma.governorate.findMany();
        if (govs.length === 0)
            throw new common_1.NotFoundException('No governorates found');
        let closest = govs[0];
        let minDist = Infinity;
        for (const g of govs) {
            const dist = Math.pow(g.latitude - dto.latitude, 2) + Math.pow(g.longitude - dto.longitude, 2);
            if (dist < minDist) {
                minDist = dist;
                closest = g;
            }
        }
        const delegations = await this.prisma.delegation.findMany({ where: { governorateId: closest.id } });
        let closestDel = delegations.length > 0 ? delegations[0] : null;
        if (closestDel && delegations.length > 1) {
            let minDelDist = Infinity;
            for (const d of delegations) {
                if (d.latitude != null && d.longitude != null) {
                    const dist = Math.pow(d.latitude - dto.latitude, 2) + Math.pow(d.longitude - dto.longitude, 2);
                    if (dist < minDelDist) {
                        minDelDist = dist;
                        closestDel = d;
                    }
                }
            }
        }
        return {
            governorate: { id: closest.id, name: closest.name, nameAr: closest.nameAr, nameFr: closest.nameFr },
            delegation: closestDel ? { id: closestDel.id, name: closestDel.name, nameAr: closestDel.nameAr, nameFr: closestDel.nameFr } : null,
        };
    }
};
exports.GeolocationController = GeolocationController;
__decorate([
    (0, common_1.Post)('nearest'),
    openapi.ApiResponse({ status: 201, type: require("./dto/geolocation.dto").NearestLocationResponseDto }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [geolocation_dto_1.NearestLocationDto]),
    __metadata("design:returntype", Promise)
], GeolocationController.prototype, "findNearest", null);
exports.GeolocationController = GeolocationController = __decorate([
    (0, common_1.Controller)('api/geolocation'),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], GeolocationController);
//# sourceMappingURL=geolocation.controller.js.map