// @ts-nocheck
import type { ProductImageDto } from './productImageDto';
import type { ProductMerchantDto } from './productMerchantDto';

export interface ProductDetailResponseDto {
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
  images: ProductImageDto[];
  isFavorited: boolean;
  createdAt: string;
}
