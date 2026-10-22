"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const app_module_1 = require("./app.module");
async function bootstrap() {
    const app = await core_1.NestFactory.create(app_module_1.AppModule);
    app.enableCors({ origin: '*' });
    app.useGlobalPipes(new common_1.ValidationPipe({ whitelist: true, transform: true }));
    const swaggerPath = 'api-docs';
    app.use(`/${swaggerPath}`, (req, res, next) => {
        res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate');
        res.setHeader('Pragma', 'no-cache');
        res.setHeader('Expires', '0');
        res.setHeader('Surrogate-Control', 'no-store');
        next();
    });
    const config = new swagger_1.DocumentBuilder()
        .setTitle('Hwenti API')
        .setDescription('\u062d\u0648\u0627\u0646\u062a\u064a - Tunisian Marketplace API')
        .setVersion('1.0')
        .addBearerAuth()
        .build();
    const document = swagger_1.SwaggerModule.createDocument(app, config);
    swagger_1.SwaggerModule.setup(swaggerPath, app, document, {
        customSiteTitle: 'Hwenti API',
        customCss: `
      .swagger-ui .topbar { display: none; }
      .swagger-ui { font-family: system-ui, -apple-system, sans-serif; }
      .swagger-ui .info .title { color: #1A1A1A; }
    `,
        swaggerOptions: { layout: 'BaseLayout' },
    });
    await app.listen(process.env.PORT ?? 3333);
}
bootstrap();
//# sourceMappingURL=main.js.map