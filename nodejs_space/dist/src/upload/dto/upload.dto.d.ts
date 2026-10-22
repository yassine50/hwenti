export declare class PresignedUploadDto {
    fileName: string;
    contentType: string;
    isPublic?: boolean;
}
export declare class CompleteUploadDto {
    cloud_storage_path: string;
    fileName: string;
    contentType: string;
    fileSize?: number;
}
export declare class PresignedUploadResponseDto {
    uploadUrl: string;
    cloud_storage_path: string;
}
export declare class CompleteUploadResponseDto {
    id: string;
    cloud_storage_path: string;
    fileName: string;
}
export declare class FileUrlResponseDto {
    url: string;
}
export declare class DeleteFileResponseDto {
    success: boolean;
}
