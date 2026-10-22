import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { PrismaService } from '../prisma/prisma.service';
import { SignupDto } from './dto/signup.dto';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async signup(dto: SignupDto) {
    const existing = await this.prisma.user.findUnique({ where: { email: dto.email } });
    if (existing) throw new ConflictException('Email already registered');

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

  async login(dto: LoginDto) {
    const user = await this.prisma.user.findUnique({
      where: { email: dto.email },
      include: { merchant: true },
    });
    if (!user) throw new UnauthorizedException('Invalid credentials');

    const valid = await bcrypt.compare(dto.password, user.password);
    if (!valid) throw new UnauthorizedException('Invalid credentials');

    const merchantSetupComplete = user.role === 'visitor' ? true : (user.merchant?.setupComplete ?? false);
    const token = this.jwtService.sign({ sub: user.id, email: user.email });
    return {
      token,
      user: { id: user.id, email: user.email, name: user.name, role: user.role, merchantSetupComplete },
    };
  }

  async googleAuth(dto: { email: string; name?: string; role?: string }) {
    const email = (dto.email || '').trim().toLowerCase();
    if (!email) throw new UnauthorizedException('Invalid Google email');

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

    if (!user) throw new UnauthorizedException('Google authentication failed');

    const merchantSetupComplete =
      user.role === 'visitor' ? true : (user.merchant?.setupComplete ?? false);
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

  async me(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { merchant: true },
    });
    if (!user) throw new UnauthorizedException('User not found');
    const merchantSetupComplete = user.role === 'visitor' ? true : (user.merchant?.setupComplete ?? false);
    return {
      user: { id: user.id, email: user.email, name: user.name, role: user.role, merchantSetupComplete },
    };
  }
}
