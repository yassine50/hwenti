import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma/prisma.service';
import { SignupDto } from './dto/signup.dto';
import { LoginDto } from './dto/login.dto';
export declare class AuthService {
    private prisma;
    private jwtService;
    constructor(prisma: PrismaService, jwtService: JwtService);
    signup(dto: SignupDto): Promise<{
        token: string;
        user: {
            id: string;
            email: string;
            name: string;
            role: string;
            merchantSetupComplete: boolean;
        };
    }>;
    login(dto: LoginDto): Promise<{
        token: string;
        user: {
            id: string;
            email: string;
            name: string;
            role: string;
            merchantSetupComplete: boolean;
        };
    }>;
    googleAuth(dto: {
        email: string;
        name?: string;
        role?: string;
    }): Promise<{
        token: string;
        user: {
            id: string;
            email: string;
            name: string;
            role: string;
            merchantSetupComplete: boolean;
        };
    }>;
    me(userId: string): Promise<{
        user: {
            id: string;
            email: string;
            name: string;
            role: string;
            merchantSetupComplete: boolean;
        };
    }>;
}
