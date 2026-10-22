"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const jwt_1 = require("@nestjs/jwt");
const bcrypt = __importStar(require("bcryptjs"));
const prisma_service_1 = require("../prisma/prisma.service");
let AuthService = class AuthService {
    prisma;
    jwtService;
    constructor(prisma, jwtService) {
        this.prisma = prisma;
        this.jwtService = jwtService;
    }
    async signup(dto) {
        const existing = await this.prisma.user.findUnique({ where: { email: dto.email } });
        if (existing)
            throw new common_1.ConflictException('Email already registered');
        const hashed = await bcrypt.hash(dto.password, 10);
        const user = await this.prisma.user.create({
            data: { email: dto.email, password: hashed, name: dto.name, role: dto.role },
        });
        let merchantSetupComplete = true;
        if (dto.role === 'merchant') {
            await this.prisma.merchant.create({ data: { userId: user.id } });
            merchantSetupComplete = false;
        }
        const token = this.jwtService.sign({ sub: user.id, email: user.email });
        return {
            token,
            user: { id: user.id, email: user.email, name: user.name, role: user.role, merchantSetupComplete },
        };
    }
    async login(dto) {
        const user = await this.prisma.user.findUnique({
            where: { email: dto.email },
            include: { merchant: true },
        });
        if (!user)
            throw new common_1.UnauthorizedException('Invalid credentials');
        const valid = await bcrypt.compare(dto.password, user.password);
        if (!valid)
            throw new common_1.UnauthorizedException('Invalid credentials');
        const merchantSetupComplete = user.role === 'visitor' ? true : (user.merchant?.setupComplete ?? false);
        const token = this.jwtService.sign({ sub: user.id, email: user.email });
        return {
            token,
            user: { id: user.id, email: user.email, name: user.name, role: user.role, merchantSetupComplete },
        };
    }
    async googleAuth(dto) {
        const email = (dto.email || '').trim().toLowerCase();
        if (!email)
            throw new common_1.UnauthorizedException('Invalid Google email');
        let user = await this.prisma.user.findUnique({
            where: { email },
            include: { merchant: true },
        });
        if (!user) {
            const role = dto.role === 'merchant' ? 'merchant' : 'visitor';
            const displayName = (dto.name && dto.name.trim().length > 0)
                ? dto.name.trim()
                : email.split('@')[0];
            const randomPass = await bcrypt.hash(`google_oauth_${Date.now()}`, 10);
            const created = await this.prisma.user.create({
                data: {
                    email,
                    password: randomPass,
                    name: displayName,
                    role,
                },
            });
            if (role === 'merchant') {
                await this.prisma.merchant.create({ data: { userId: created.id } });
            }
            user = await this.prisma.user.findUnique({
                where: { id: created.id },
                include: { merchant: true },
            });
        }
        if (!user)
            throw new common_1.UnauthorizedException('Google authentication failed');
        const merchantSetupComplete = user.role === 'visitor' ? true : (user.merchant?.setupComplete ?? false);
        const token = this.jwtService.sign({ sub: user.id, email: user.email });
        return {
            token,
            user: {
                id: user.id,
                email: user.email,
                name: user.name,
                role: user.role,
                merchantSetupComplete,
            },
        };
    }
    async me(userId) {
        const user = await this.prisma.user.findUnique({
            where: { id: userId },
            include: { merchant: true },
        });
        if (!user)
            throw new common_1.UnauthorizedException('User not found');
        const merchantSetupComplete = user.role === 'visitor' ? true : (user.merchant?.setupComplete ?? false);
        return {
            user: { id: user.id, email: user.email, name: user.name, role: user.role, merchantSetupComplete },
        };
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        jwt_1.JwtService])
], AuthService);
//# sourceMappingURL=auth.service.js.map