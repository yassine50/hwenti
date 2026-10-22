import { PrismaService } from '../prisma/prisma.service';
import { CreateProductDto, UpdateProductDto } from './dto/product.dto';
export declare class ProductsService {
    private prisma;
    constructor(prisma: PrismaService);
    private getMerchantInfo;
    private getImageUrl;
    create(userId: string, dto: CreateProductDto): Promise<{
        id: string;
        name: string;
        price: number;
        phone: string;
        description: string | null;
        expiryDate: string;
        publishDate: string;
        viewCount: number;
        isAvailable: boolean;
        merchant: {
            id: string;
            shopName: string | null;
            averageRating: number;
            logoFileId: string | null;
            logoUrl: string | null;
        };
        images: {
            id: string;
            fileId: string;
            url: string;
            isPrimary: boolean;
            sortOrder: number;
        }[];
        isFavorited: boolean;
        createdAt: string;
    }>;
    update(productId: string, userId: string, dto: UpdateProductDto): Promise<{
        id: string;
        name: string;
        price: number;
        phone: string;
        description: string | null;
        expiryDate: string;
        publishDate: string;
        viewCount: number;
        isAvailable: boolean;
        merchant: {
            id: string;
            shopName: string | null;
            averageRating: number;
            logoFileId: string | null;
            logoUrl: string | null;
        };
        images: {
            id: string;
            fileId: string;
            url: string;
            isPrimary: boolean;
            sortOrder: number;
        }[];
        isFavorited: boolean;
        createdAt: string;
    }>;
    remove(productId: string, userId: string): Promise<{
        success: boolean;
    }>;
    findOne(id: string, userId?: string | null): Promise<{
        id: string;
        name: string;
        price: number;
        phone: string;
        description: string | null;
        expiryDate: string;
        publishDate: string;
        viewCount: number;
        isAvailable: boolean;
        merchant: {
            id: string;
            shopName: string | null;
            averageRating: number;
            logoFileId: string | null;
            logoUrl: string | null;
        };
        images: {
            id: string;
            fileId: string;
            url: string;
            isPrimary: boolean;
            sortOrder: number;
        }[];
        isFavorited: boolean;
        createdAt: string;
    }>;
    incrementView(id: string): Promise<{
        viewCount: number;
    }>;
    findAll(query: {
        governorateId?: string;
        delegationId?: string;
        tradeType?: string;
        merchantId?: string;
        search?: string;
        available?: string;
        page?: number;
        limit?: number;
    }, userId?: string | null): Promise<{
        items: {
            id: string;
            name: string;
            price: number;
            phone: string;
            description: string | null;
            expiryDate: string;
            publishDate: string;
            viewCount: number;
            isAvailable: boolean;
            merchant: {
                id: string;
                shopName: string | null;
                averageRating: number;
                logoFileId: string | null;
                logoUrl: string | null;
            };
            primaryImageUrl: string | null;
            imageCount: number;
            isFavorited: boolean;
            createdAt: string;
        }[];
        total: number;
        page: number;
        totalPages: number;
    }>;
    findMine(userId: string, page?: number, limit?: number): Promise<{
        items: {
            id: string;
            name: string;
            price: number;
            phone: string;
            description: string | null;
            expiryDate: string;
            publishDate: string;
            viewCount: number;
            isAvailable: boolean;
            merchant: {
                id: string;
                shopName: string | null;
                averageRating: number;
                logoFileId: string | null;
                logoUrl: string | null;
            };
            primaryImageUrl: string | null;
            imageCount: number;
            isFavorited: boolean;
            createdAt: string;
        }[];
        total: number;
        page: number;
        totalPages: number;
    }>;
}
