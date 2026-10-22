// @ts-nocheck
import type { ProductMerchantDto } from './productMerchantDto';

export interface ProductListItemDto {
  id: string;
  name: string;
  price: number;
  phone: string;
  /** @nullable */
  description: string | null;
  expiryDate: string;
  publishDate: string;
  viewCount: number;
  isAvailable: boolean;
  merchant: ProductMerchantDto;
  /** @nullable */
  primaryImageUrl: string | null;
  imageCount: number;
  isFavorited: boolean;
  createdAt: string;
}
