// @ts-nocheck
import type { NotificationItemDto } from './notificationItemDto';

export interface NotificationListResponseDto {
  items: NotificationItemDto[];
  total: number;
  page: number;
  totalPages: number;
}
