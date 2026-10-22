import { ProductListItemDto } from '../../products/dto/product.dto';
export declare class FavoriteSuccessDto {
    success: boolean;
}
export declare class FavoriteListResponseDto {
    items: ProductListItemDto[];
    total: number;
    page: number;
    totalPages: number;
}
