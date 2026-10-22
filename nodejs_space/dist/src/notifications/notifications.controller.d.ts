import type { Request } from 'express';
import { PrismaService } from '../prisma/prisma.service';
import { NotificationListResponseDto, NotificationReadResponseDto } from './dto/notification.dto';
export declare class NotificationsController {
    private prisma;
    constructor(prisma: PrismaService);
    findAll(req: Request, page?: number, limit?: number): Promise<NotificationListResponseDto>;
    markRead(id: string, req: Request): Promise<NotificationReadResponseDto>;
}
