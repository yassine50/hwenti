// @ts-nocheck

export interface MerchantResponseDto {
  id: string;
  userId: string;
  /** @nullable */
  shopName: string | null;
  /** @nullable */
  tradeType: string | null;
  /** @nullable */
  governorateId: string | null;
  /** @nullable */
  governorateName: string | null;
  /** @nullable */
  delegationId: string | null;
  /** @nullable */
  delegationName: string | null;
  /** @nullable */
  phone: string | null;
  /** @nullable */
  logoFileId: string | null;
  /** @nullable */
  logoUrl: string | null;
  averageRating: number;
  ratingCount: number;
  setupComplete: boolean;
  createdAt: string;
}
