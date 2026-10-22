// @ts-nocheck

export interface MerchantListItemDto {
  id: string;
  userId: string;
  /** @nullable */
  shopName: string | null;
  /** @nullable */
  tradeType: string | null;
  /** @nullable */
  governorateName: string | null;
  /** @nullable */
  logoFileId: string | null;
  /** @nullable */
  logoUrl: string | null;
  averageRating: number;
  ratingCount: number;
}
