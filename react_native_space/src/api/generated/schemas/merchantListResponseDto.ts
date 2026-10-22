// @ts-nocheck
import type { MerchantListItemDto } from './merchantListItemDto';

export interface MerchantListResponseDto {
  items: MerchantListItemDto[];
  total: number;
  page: number;
  totalPages: number;
}
