export declare class NotificationItemDto {
    id: string;
    type: string;
    message: string;
    productId: string | null;
    merchantId: string;
    merchantName: string | null;
    merchantLogoUrl: string | null;
    isRead: boolean;
    createdAt: string;
}
export declare class NotificationListResponseDto {
    items: NotificationItemDto[];
    total: number;
    page: number;
    totalPages: number;
}
export declare class NotificationReadResponseDto {
    success: boolean;
}
