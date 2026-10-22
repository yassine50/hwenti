import { PrismaService } from '../prisma/prisma.service';
import { NearestLocationDto, NearestLocationResponseDto } from './dto/geolocation.dto';
export declare class GeolocationController {
    private prisma;
    constructor(prisma: PrismaService);
    findNearest(dto: NearestLocationDto): Promise<NearestLocationResponseDto>;
}
