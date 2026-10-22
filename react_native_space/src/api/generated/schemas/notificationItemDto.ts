// @ts-nocheck

export interface NotificationItemDto {
  id: string;
  type: string;
  message: string;
  /** @nullable */
  productId: string | null;
  merchantId: string;
  /** @nullable */
  merchantName: string | null;
  /** @nullable */
  merchantLogoUrl: string | null;
  isRead: boolean;
  createdAt: string;
}
