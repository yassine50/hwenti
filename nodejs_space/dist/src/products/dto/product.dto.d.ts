export declare class CreateProductDto {
    name: string;
    price: number;
    phone: string;
    description?: string;
    expiryDate: string;
    publishDate?: string;
    imageFileIds: string[];
}
export declare class UpdateProductDto {
    name?: string;
    price?: number;
    phone?: string;
    description?: string;
    expiryDate?: string;
    publishDate?: string;
    imageFileIds?: string[];
}
export declare class ProductImageDto {
    id: string;
    fileId: string;
    url: string;
    isPrimary: boolean;
    sortOrder: number;
}
export declare class ProductMerchantDto {
    id: string;
    shopName: string | null;
    averageRating: number;
    logoFileId: string | null;
    logoUrl: string | null;
}
export declare class ProductDetailResponseDto {
    id: string;
    name: string;
    price: number;
    phone: string;
    description: string | null;
    expiryDate: string;
    publishDate: string;
    viewCount: number;
    isAvailable: boolean;
    merchant: ProductMerchantDto;
    images: ProductImageDto[];
    isFavorited: boolean;
    createdAt: string;
}
export declare class ProductListItemDto {
    id: string;
    name: string;
    price: number;
    phone: string;
    description: string | null;
    expiryDate: string;
    publishDate: string;
    viewCount: number;
    isAvailable: boolean;
    merchant: ProductMerchantDto;
    primaryImageUrl: string | null;
    imageCount: number;
    isFavorited: boolean;
    createdAt: string;
}
export declare class ProductListResponseDto {
    items: ProductListItemDto[];
    total: number;
    page: number;
    totalPages: number;
}
export declare class ViewCountResponseDto {
    viewCount: number;
}
export declare class SuccessResponseDto {
    success: boolean;
}
