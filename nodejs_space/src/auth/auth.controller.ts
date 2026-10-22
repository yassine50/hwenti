import { Controller, Post, Get, Body, UseGuards, Req } from '@nestjs/common';
import type { Request } from 'express';
import { AuthService } from './auth.service';
import { SignupDto } from './dto/signup.dto';
import { LoginDto } from './dto/login.dto';
import { JwtAuthGuard } from './jwt-auth.guard';
import { AuthResponseDto, MeResponseDto } from './dto/auth-response.dto';

@Controller()
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post('api/signup')
  async signup(@Body() dto: SignupDto): Promise<AuthResponseDto> {
    return this.authService.signup(dto);
  }

  @Post('api/auth/login')
  async login(@Body() dto: LoginDto): Promise<AuthResponseDto> {
    return this.authService.login(dto);
  }

  @Post('api/auth/google')
  async googleAuth(
    @Body() body: { email: string; name?: string; role?: string },
  ): Promise<AuthResponseDto> {
    return this.authService.googleAuth(body);
  }

  @Get('api/auth/me')
  @UseGuards(JwtAuthGuard)
  async me(@Req() req: Request): Promise<MeResponseDto> {
    const user = req.user as { id: string };
    return this.authService.me(user.id);
  }
}
