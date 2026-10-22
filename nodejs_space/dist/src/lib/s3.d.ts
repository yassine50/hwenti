export declare function generatePresignedUploadUrl(fileName: string, contentType: string, isPublic?: boolean): Promise<{
    uploadUrl: string;
    cloud_storage_path: string;
}>;
export declare function getFileUrl(cloud_storage_path: string, contentType: string, isPublic: boolean): Promise<string>;
export declare function deleteFile(cloud_storage_path: string): Promise<void>;
