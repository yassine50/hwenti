// @ts-nocheck
import type { ProductListItemDto } from './productListItemDto';

export interface ProductListResponseDto {
  items: ProductListItemDto[];
  total: number;
  page: number;
  totalPages: number;
}
