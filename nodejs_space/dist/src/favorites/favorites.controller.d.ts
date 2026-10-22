import type { Request } from 'express';
import { PrismaService } from '../prisma/prisma.service';
import { ProductsService } from '../products/products.service';
import { FavoriteSuccessDto, FavoriteListResponseDto } from './dto/favorite.dto';
export declare class FavoritesController {
    private prisma;
    private productsService;
    constructor(prisma: PrismaService, productsService: ProductsService);
    add(productId: string, req: Request): Promise<FavoriteSuccessDto>;
    remove(productId: string, req: Request): Promise<FavoriteSuccessDto>;
    findAll(req: Request, page?: number, limit?: number): Promise<FavoriteListResponseDto>;
}
