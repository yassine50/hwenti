// @ts-nocheck
import type { ProductListItemDto } from './productListItemDto';

export interface FavoriteListResponseDto {
  items: ProductListItemDto[];
  total: number;
  page: number;
  totalPages: number;
}
