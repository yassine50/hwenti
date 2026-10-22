// @ts-nocheck
import {
  useMutation,
  useQuery
} from '@tanstack/react-query';
import type {
  DataTag,
  DefinedInitialDataOptions,
  DefinedUseQueryResult,
  MutationFunction,
  QueryClient,
  QueryFunction,
  QueryKey,
  UndefinedInitialDataOptions,
  UseMutationOptions,
  UseMutationResult,
  UseQueryOptions,
  UseQueryResult
} from '@tanstack/react-query';

import type {
  AuthResponseDto,
  CompleteUploadDto,
  CompleteUploadResponseDto,
  CreateProductDto,
  CreateRatingDto,
  CreateReportDto,
  DelegationListResponseDto,
  DeleteFileResponseDto,
  FavoriteListResponseDto,
  FavoriteSuccessDto,
  FavoritesControllerFindAllParams,
  FileUrlResponseDto,
  FollowListResponseDto,
  FollowSuccessDto,
  FollowsControllerFindAllParams,
  GovernorateListResponseDto,
  LoginDto,
  MeResponseDto,
  MerchantListResponseDto,
  MerchantResponseDto,
  MerchantSetupDto,
  MerchantUpdateDto,
  MerchantsControllerFindAllParams,
  NearestLocationDto,
  NearestLocationResponseDto,
  NotificationListResponseDto,
  NotificationReadResponseDto,
  NotificationsControllerFindAllParams,
  PresignedUploadDto,
  PresignedUploadResponseDto,
  ProductDetailResponseDto,
  ProductListResponseDto,
  ProductsControllerFindAllParams,
  ProductsControllerFindMineParams,
  RatingListResponseDto,
  RatingResponseDto,
  RatingsControllerFindAllParams,
  ReportResponseDto,
  SignupDto,
  SuccessResponseDto,
  TrackVisitorDto,
  TrackVisitorResponseDto,
  UpdateProductDto,
  UploadControllerGetUrlParams,
  ViewCountResponseDto,
  VisitorStatsSummaryResponseDto
} from './schemas';

import { customFetch } from '../customFetch';
import type { ErrorType , BodyType } from '../customFetch';


type SecondParameter<T extends (...args: never) => unknown> = Parameters<T>[1];



export const getAuthControllerSignupUrl = () => {




  return `/api/signup`
}

export const authControllerSignup = async (signupDto: SignupDto, options?: RequestInit): Promise<AuthResponseDto> => {

  return customFetch<AuthResponseDto>(getAuthControllerSignupUrl(),
  {
    ...options,
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...options?.headers },
    body: JSON.stringify(signupDto)
  }
);}




export const getAuthControllerSignupMutationOptions = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof authControllerSignup>>, TError,{data: BodyType<SignupDto>}, TContext>, request?: SecondParameter<typeof customFetch>}
): UseMutationOptions<Awaited<ReturnType<typeof authControllerSignup>>, TError,{data: BodyType<SignupDto>}, TContext> => {

const mutationKey = ['authControllerSignup'];
const {mutation: mutationOptions, request: requestOptions} = options ?
      options.mutation && 'mutationKey' in options.mutation && options.mutation.mutationKey ?
      options
      : {...options, mutation: {...options.mutation, mutationKey}}
      : {mutation: { mutationKey, }, request: undefined};




      const mutationFn: MutationFunction<Awaited<ReturnType<typeof authControllerSignup>>, {data: BodyType<SignupDto>}> = (props) => {
          const {data} = props ?? {};

          return  authControllerSignup(data,requestOptions)
        }






  return  { mutationFn, ...mutationOptions }}

    export type AuthControllerSignupMutationResult = NonNullable<Awaited<ReturnType<typeof authControllerSignup>>>
    export type AuthControllerSignupMutationBody = BodyType<SignupDto>
    export type AuthControllerSignupMutationError = ErrorType<unknown>

    export const useAuthControllerSignup = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof authControllerSignup>>, TError,{data: BodyType<SignupDto>}, TContext>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient): UseMutationResult<
        Awaited<ReturnType<typeof authControllerSignup>>,
        TError,
        {data: BodyType<SignupDto>},
        TContext
      > => {
      return useMutation(getAuthControllerSignupMutationOptions(options), queryClient);
    }

export const getAuthControllerLoginUrl = () => {




  return `/api/auth/login`
}

export const authControllerLogin = async (loginDto: LoginDto, options?: RequestInit): Promise<AuthResponseDto> => {

  return customFetch<AuthResponseDto>(getAuthControllerLoginUrl(),
  {
    ...options,
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...options?.headers },
    body: JSON.stringify(loginDto)
  }
);}




export const getAuthControllerLoginMutationOptions = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof authControllerLogin>>, TError,{data: BodyType<LoginDto>}, TContext>, request?: SecondParameter<typeof customFetch>}
): UseMutationOptions<Awaited<ReturnType<typeof authControllerLogin>>, TError,{data: BodyType<LoginDto>}, TContext> => {

const mutationKey = ['authControllerLogin'];
const {mutation: mutationOptions, request: requestOptions} = options ?
      options.mutation && 'mutationKey' in options.mutation && options.mutation.mutationKey ?
      options
      : {...options, mutation: {...options.mutation, mutationKey}}
      : {mutation: { mutationKey, }, request: undefined};




      const mutationFn: MutationFunction<Awaited<ReturnType<typeof authControllerLogin>>, {data: BodyType<LoginDto>}> = (props) => {
          const {data} = props ?? {};

          return  authControllerLogin(data,requestOptions)
        }






  return  { mutationFn, ...mutationOptions }}

    export type AuthControllerLoginMutationResult = NonNullable<Awaited<ReturnType<typeof authControllerLogin>>>
    export type AuthControllerLoginMutationBody = BodyType<LoginDto>
    export type AuthControllerLoginMutationError = ErrorType<unknown>

    export const useAuthControllerLogin = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof authControllerLogin>>, TError,{data: BodyType<LoginDto>}, TContext>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient): UseMutationResult<
        Awaited<ReturnType<typeof authControllerLogin>>,
        TError,
        {data: BodyType<LoginDto>},
        TContext
      > => {
      return useMutation(getAuthControllerLoginMutationOptions(options), queryClient);
    }

export const getAuthControllerMeUrl = () => {




  return `/api/auth/me`
}

export const authControllerMe = async ( options?: RequestInit): Promise<MeResponseDto> => {

  return customFetch<MeResponseDto>(getAuthControllerMeUrl(),
  {
    ...options,
    method: 'GET'


  }
);}





export const getAuthControllerMeQueryKey = () => {
    return [
    `/api/auth/me`
    ] as const;
    }


export const getAuthControllerMeQueryOptions = <TData = Awaited<ReturnType<typeof authControllerMe>>, TError = ErrorType<unknown>>( options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof authControllerMe>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
) => {

const {query: queryOptions, request: requestOptions} = options ?? {};

  const queryKey =  queryOptions?.queryKey ?? getAuthControllerMeQueryKey();



    const queryFn: QueryFunction<Awaited<ReturnType<typeof authControllerMe>>> = ({ signal }) => authControllerMe({ signal, ...requestOptions });





   return  { queryKey, queryFn, ...queryOptions} as UseQueryOptions<Awaited<ReturnType<typeof authControllerMe>>, TError, TData> & { queryKey: DataTag<QueryKey, TData, TError> }
}

export type AuthControllerMeQueryResult = NonNullable<Awaited<ReturnType<typeof authControllerMe>>>
export type AuthControllerMeQueryError = ErrorType<unknown>


export function useAuthControllerMe<TData = Awaited<ReturnType<typeof authControllerMe>>, TError = ErrorType<unknown>>(
  options: { query:Partial<UseQueryOptions<Awaited<ReturnType<typeof authControllerMe>>, TError, TData>> & Pick<
        DefinedInitialDataOptions<
          Awaited<ReturnType<typeof authControllerMe>>,
          TError,
          Awaited<ReturnType<typeof authControllerMe>>
        > , 'initialData'
      >, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  DefinedUseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }
export function useAuthControllerMe<TData = Awaited<ReturnType<typeof authControllerMe>>, TError = ErrorType<unknown>>(
  options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof authControllerMe>>, TError, TData>> & Pick<
        UndefinedInitialDataOptions<
          Awaited<ReturnType<typeof authControllerMe>>,
          TError,
          Awaited<ReturnType<typeof authControllerMe>>
        > , 'initialData'
      >, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }
export function useAuthControllerMe<TData = Awaited<ReturnType<typeof authControllerMe>>, TError = ErrorType<unknown>>(
  options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof authControllerMe>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }

export function useAuthControllerMe<TData = Awaited<ReturnType<typeof authControllerMe>>, TError = ErrorType<unknown>>(
  options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof authControllerMe>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
 ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> } {

  const queryOptions = getAuthControllerMeQueryOptions(options)

  const query = useQuery(queryOptions, queryClient) as  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> };

  return { ...query, queryKey: queryOptions.queryKey };
}







export const getGovernoratesControllerFindAllUrl = () => {




  return `/api/governorates`
}

export const governoratesControllerFindAll = async ( options?: RequestInit): Promise<GovernorateListResponseDto> => {

  return customFetch<GovernorateListResponseDto>(getGovernoratesControllerFindAllUrl(),
  {
    ...options,
    method: 'GET'


  }
);}





export const getGovernoratesControllerFindAllQueryKey = () => {
    return [
    `/api/governorates`
    ] as const;
    }


export const getGovernoratesControllerFindAllQueryOptions = <TData = Awaited<ReturnType<typeof governoratesControllerFindAll>>, TError = ErrorType<unknown>>( options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof governoratesControllerFindAll>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
) => {

const {query: queryOptions, request: requestOptions} = options ?? {};

  const queryKey =  queryOptions?.queryKey ?? getGovernoratesControllerFindAllQueryKey();



    const queryFn: QueryFunction<Awaited<ReturnType<typeof governoratesControllerFindAll>>> = ({ signal }) => governoratesControllerFindAll({ signal, ...requestOptions });





   return  { queryKey, queryFn, ...queryOptions} as UseQueryOptions<Awaited<ReturnType<typeof governoratesControllerFindAll>>, TError, TData> & { queryKey: DataTag<QueryKey, TData, TError> }
}

export type GovernoratesControllerFindAllQueryResult = NonNullable<Awaited<ReturnType<typeof governoratesControllerFindAll>>>
export type GovernoratesControllerFindAllQueryError = ErrorType<unknown>


export function useGovernoratesControllerFindAll<TData = Awaited<ReturnType<typeof governoratesControllerFindAll>>, TError = ErrorType<unknown>>(
  options: { query:Partial<UseQueryOptions<Awaited<ReturnType<typeof governoratesControllerFindAll>>, TError, TData>> & Pick<
        DefinedInitialDataOptions<
          Awaited<ReturnType<typeof governoratesControllerFindAll>>,
          TError,
          Awaited<ReturnType<typeof governoratesControllerFindAll>>
        > , 'initialData'
      >, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  DefinedUseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }
export function useGovernoratesControllerFindAll<TData = Awaited<ReturnType<typeof governoratesControllerFindAll>>, TError = ErrorType<unknown>>(
  options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof governoratesControllerFindAll>>, TError, TData>> & Pick<
        UndefinedInitialDataOptions<
          Awaited<ReturnType<typeof governoratesControllerFindAll>>,
          TError,
          Awaited<ReturnType<typeof governoratesControllerFindAll>>
        > , 'initialData'
      >, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }
export function useGovernoratesControllerFindAll<TData = Awaited<ReturnType<typeof governoratesControllerFindAll>>, TError = ErrorType<unknown>>(
  options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof governoratesControllerFindAll>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }

export function useGovernoratesControllerFindAll<TData = Awaited<ReturnType<typeof governoratesControllerFindAll>>, TError = ErrorType<unknown>>(
  options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof governoratesControllerFindAll>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
 ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> } {

  const queryOptions = getGovernoratesControllerFindAllQueryOptions(options)

  const query = useQuery(queryOptions, queryClient) as  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> };

  return { ...query, queryKey: queryOptions.queryKey };
}







export const getGovernoratesControllerFindDelegationsUrl = (id: string,) => {




  return `/api/governorates/${id}/delegations`
}

export const governoratesControllerFindDelegations = async (id: string, options?: RequestInit): Promise<DelegationListResponseDto> => {

  return customFetch<DelegationListResponseDto>(getGovernoratesControllerFindDelegationsUrl(id),
  {
    ...options,
    method: 'GET'


  }
);}





export const getGovernoratesControllerFindDelegationsQueryKey = (id: string,) => {
    return [
    `/api/governorates/${id}/delegations`
    ] as const;
    }


export const getGovernoratesControllerFindDelegationsQueryOptions = <TData = Awaited<ReturnType<typeof governoratesControllerFindDelegations>>, TError = ErrorType<unknown>>(id: string, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof governoratesControllerFindDelegations>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
) => {

const {query: queryOptions, request: requestOptions} = options ?? {};

  const queryKey =  queryOptions?.queryKey ?? getGovernoratesControllerFindDelegationsQueryKey(id);



    const queryFn: QueryFunction<Awaited<ReturnType<typeof governoratesControllerFindDelegations>>> = ({ signal }) => governoratesControllerFindDelegations(id, { signal, ...requestOptions });





   return  { queryKey, queryFn, enabled: id !== null && id !== undefined, ...queryOptions} as UseQueryOptions<Awaited<ReturnType<typeof governoratesControllerFindDelegations>>, TError, TData> & { queryKey: DataTag<QueryKey, TData, TError> }
}

export type GovernoratesControllerFindDelegationsQueryResult = NonNullable<Awaited<ReturnType<typeof governoratesControllerFindDelegations>>>
export type GovernoratesControllerFindDelegationsQueryError = ErrorType<unknown>


export function useGovernoratesControllerFindDelegations<TData = Awaited<ReturnType<typeof governoratesControllerFindDelegations>>, TError = ErrorType<unknown>>(
 id: string, options: { query:Partial<UseQueryOptions<Awaited<ReturnType<typeof governoratesControllerFindDelegations>>, TError, TData>> & Pick<
        DefinedInitialDataOptions<
          Awaited<ReturnType<typeof governoratesControllerFindDelegations>>,
          TError,
          Awaited<ReturnType<typeof governoratesControllerFindDelegations>>
        > , 'initialData'
      >, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  DefinedUseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }
export function useGovernoratesControllerFindDelegations<TData = Awaited<ReturnType<typeof governoratesControllerFindDelegations>>, TError = ErrorType<unknown>>(
 id: string, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof governoratesControllerFindDelegations>>, TError, TData>> & Pick<
        UndefinedInitialDataOptions<
          Awaited<ReturnType<typeof governoratesControllerFindDelegations>>,
          TError,
          Awaited<ReturnType<typeof governoratesControllerFindDelegations>>
        > , 'initialData'
      >, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }
export function useGovernoratesControllerFindDelegations<TData = Awaited<ReturnType<typeof governoratesControllerFindDelegations>>, TError = ErrorType<unknown>>(
 id: string, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof governoratesControllerFindDelegations>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }

export function useGovernoratesControllerFindDelegations<TData = Awaited<ReturnType<typeof governoratesControllerFindDelegations>>, TError = ErrorType<unknown>>(
 id: string, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof governoratesControllerFindDelegations>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
 ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> } {

  const queryOptions = getGovernoratesControllerFindDelegationsQueryOptions(id,options)

  const query = useQuery(queryOptions, queryClient) as  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> };

  return { ...query, queryKey: queryOptions.queryKey };
}







export const getUploadControllerPresignedUrl = () => {




  return `/api/upload/presigned`
}

export const uploadControllerPresigned = async (presignedUploadDto: PresignedUploadDto, options?: RequestInit): Promise<PresignedUploadResponseDto> => {

  return customFetch<PresignedUploadResponseDto>(getUploadControllerPresignedUrl(),
  {
    ...options,
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...options?.headers },
    body: JSON.stringify(presignedUploadDto)
  }
);}




export const getUploadControllerPresignedMutationOptions = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof uploadControllerPresigned>>, TError,{data: BodyType<PresignedUploadDto>}, TContext>, request?: SecondParameter<typeof customFetch>}
): UseMutationOptions<Awaited<ReturnType<typeof uploadControllerPresigned>>, TError,{data: BodyType<PresignedUploadDto>}, TContext> => {

const mutationKey = ['uploadControllerPresigned'];
const {mutation: mutationOptions, request: requestOptions} = options ?
      options.mutation && 'mutationKey' in options.mutation && options.mutation.mutationKey ?
      options
      : {...options, mutation: {...options.mutation, mutationKey}}
      : {mutation: { mutationKey, }, request: undefined};




      const mutationFn: MutationFunction<Awaited<ReturnType<typeof uploadControllerPresigned>>, {data: BodyType<PresignedUploadDto>}> = (props) => {
          const {data} = props ?? {};

          return  uploadControllerPresigned(data,requestOptions)
        }






  return  { mutationFn, ...mutationOptions }}

    export type UploadControllerPresignedMutationResult = NonNullable<Awaited<ReturnType<typeof uploadControllerPresigned>>>
    export type UploadControllerPresignedMutationBody = BodyType<PresignedUploadDto>
    export type UploadControllerPresignedMutationError = ErrorType<unknown>

    export const useUploadControllerPresigned = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof uploadControllerPresigned>>, TError,{data: BodyType<PresignedUploadDto>}, TContext>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient): UseMutationResult<
        Awaited<ReturnType<typeof uploadControllerPresigned>>,
        TError,
        {data: BodyType<PresignedUploadDto>},
        TContext
      > => {
      return useMutation(getUploadControllerPresignedMutationOptions(options), queryClient);
    }

export const getUploadControllerCompleteUrl = () => {




  return `/api/upload/complete`
}

export const uploadControllerComplete = async (completeUploadDto: CompleteUploadDto, options?: RequestInit): Promise<CompleteUploadResponseDto> => {

  return customFetch<CompleteUploadResponseDto>(getUploadControllerCompleteUrl(),
  {
    ...options,
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...options?.headers },
    body: JSON.stringify(completeUploadDto)
  }
);}




export const getUploadControllerCompleteMutationOptions = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof uploadControllerComplete>>, TError,{data: BodyType<CompleteUploadDto>}, TContext>, request?: SecondParameter<typeof customFetch>}
): UseMutationOptions<Awaited<ReturnType<typeof uploadControllerComplete>>, TError,{data: BodyType<CompleteUploadDto>}, TContext> => {

const mutationKey = ['uploadControllerComplete'];
const {mutation: mutationOptions, request: requestOptions} = options ?
      options.mutation && 'mutationKey' in options.mutation && options.mutation.mutationKey ?
      options
      : {...options, mutation: {...options.mutation, mutationKey}}
      : {mutation: { mutationKey, }, request: undefined};




      const mutationFn: MutationFunction<Awaited<ReturnType<typeof uploadControllerComplete>>, {data: BodyType<CompleteUploadDto>}> = (props) => {
          const {data} = props ?? {};

          return  uploadControllerComplete(data,requestOptions)
        }






  return  { mutationFn, ...mutationOptions }}

    export type UploadControllerCompleteMutationResult = NonNullable<Awaited<ReturnType<typeof uploadControllerComplete>>>
    export type UploadControllerCompleteMutationBody = BodyType<CompleteUploadDto>
    export type UploadControllerCompleteMutationError = ErrorType<unknown>

    export const useUploadControllerComplete = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof uploadControllerComplete>>, TError,{data: BodyType<CompleteUploadDto>}, TContext>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient): UseMutationResult<
        Awaited<ReturnType<typeof uploadControllerComplete>>,
        TError,
        {data: BodyType<CompleteUploadDto>},
        TContext
      > => {
      return useMutation(getUploadControllerCompleteMutationOptions(options), queryClient);
    }

export const getUploadControllerGetUrlUrl = (id: string,
    params?: UploadControllerGetUrlParams,) => {
  const normalizedParams = new URLSearchParams();

  Object.entries(params || {}).forEach(([key, value]) => {

    if (value !== undefined) {
      normalizedParams.append(key, value === null ? 'null' : String(value))
    }
  });

  const stringifiedParams = normalizedParams.toString();

  return stringifiedParams.length > 0 ? `/api/files/${id}/url?${stringifiedParams}` : `/api/files/${id}/url`
}

export const uploadControllerGetUrl = async (id: string,
    params?: UploadControllerGetUrlParams, options?: RequestInit): Promise<FileUrlResponseDto> => {

  return customFetch<FileUrlResponseDto>(getUploadControllerGetUrlUrl(id,params),
  {
    ...options,
    method: 'GET'


  }
);}





export const getUploadControllerGetUrlQueryKey = (id: string,
    params?: UploadControllerGetUrlParams,) => {
    return [
    `/api/files/${id}/url`, ...(params ? [params] : [])
    ] as const;
    }


export const getUploadControllerGetUrlQueryOptions = <TData = Awaited<ReturnType<typeof uploadControllerGetUrl>>, TError = ErrorType<unknown>>(id: string,
    params?: UploadControllerGetUrlParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof uploadControllerGetUrl>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
) => {

const {query: queryOptions, request: requestOptions} = options ?? {};

  const queryKey =  queryOptions?.queryKey ?? getUploadControllerGetUrlQueryKey(id,params);



    const queryFn: QueryFunction<Awaited<ReturnType<typeof uploadControllerGetUrl>>> = ({ signal }) => uploadControllerGetUrl(id,params, { signal, ...requestOptions });





   return  { queryKey, queryFn, enabled: id !== null && id !== undefined, ...queryOptions} as UseQueryOptions<Awaited<ReturnType<typeof uploadControllerGetUrl>>, TError, TData> & { queryKey: DataTag<QueryKey, TData, TError> }
}

export type UploadControllerGetUrlQueryResult = NonNullable<Awaited<ReturnType<typeof uploadControllerGetUrl>>>
export type UploadControllerGetUrlQueryError = ErrorType<unknown>


export function useUploadControllerGetUrl<TData = Awaited<ReturnType<typeof uploadControllerGetUrl>>, TError = ErrorType<unknown>>(
 id: string,
    params: undefined |  UploadControllerGetUrlParams, options: { query:Partial<UseQueryOptions<Awaited<ReturnType<typeof uploadControllerGetUrl>>, TError, TData>> & Pick<
        DefinedInitialDataOptions<
          Awaited<ReturnType<typeof uploadControllerGetUrl>>,
          TError,
          Awaited<ReturnType<typeof uploadControllerGetUrl>>
        > , 'initialData'
      >, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  DefinedUseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }
export function useUploadControllerGetUrl<TData = Awaited<ReturnType<typeof uploadControllerGetUrl>>, TError = ErrorType<unknown>>(
 id: string,
    params?: UploadControllerGetUrlParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof uploadControllerGetUrl>>, TError, TData>> & Pick<
        UndefinedInitialDataOptions<
          Awaited<ReturnType<typeof uploadControllerGetUrl>>,
          TError,
          Awaited<ReturnType<typeof uploadControllerGetUrl>>
        > , 'initialData'
      >, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }
export function useUploadControllerGetUrl<TData = Awaited<ReturnType<typeof uploadControllerGetUrl>>, TError = ErrorType<unknown>>(
 id: string,
    params?: UploadControllerGetUrlParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof uploadControllerGetUrl>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }

export function useUploadControllerGetUrl<TData = Awaited<ReturnType<typeof uploadControllerGetUrl>>, TError = ErrorType<unknown>>(
 id: string,
    params?: UploadControllerGetUrlParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof uploadControllerGetUrl>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
 ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> } {

  const queryOptions = getUploadControllerGetUrlQueryOptions(id,params,options)

  const query = useQuery(queryOptions, queryClient) as  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> };

  return { ...query, queryKey: queryOptions.queryKey };
}







export const getUploadControllerDeleteFileRecordUrl = (id: string,) => {




  return `/api/files/${id}`
}

export const uploadControllerDeleteFileRecord = async (id: string, options?: RequestInit): Promise<DeleteFileResponseDto> => {

  return customFetch<DeleteFileResponseDto>(getUploadControllerDeleteFileRecordUrl(id),
  {
    ...options,
    method: 'DELETE'


  }
);}




export const getUploadControllerDeleteFileRecordMutationOptions = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof uploadControllerDeleteFileRecord>>, TError,{id: string}, TContext>, request?: SecondParameter<typeof customFetch>}
): UseMutationOptions<Awaited<ReturnType<typeof uploadControllerDeleteFileRecord>>, TError,{id: string}, TContext> => {

const mutationKey = ['uploadControllerDeleteFileRecord'];
const {mutation: mutationOptions, request: requestOptions} = options ?
      options.mutation && 'mutationKey' in options.mutation && options.mutation.mutationKey ?
      options
      : {...options, mutation: {...options.mutation, mutationKey}}
      : {mutation: { mutationKey, }, request: undefined};




      const mutationFn: MutationFunction<Awaited<ReturnType<typeof uploadControllerDeleteFileRecord>>, {id: string}> = (props) => {
          const {id} = props ?? {};

          return  uploadControllerDeleteFileRecord(id,requestOptions)
        }






  return  { mutationFn, ...mutationOptions }}

    export type UploadControllerDeleteFileRecordMutationResult = NonNullable<Awaited<ReturnType<typeof uploadControllerDeleteFileRecord>>>

    export type UploadControllerDeleteFileRecordMutationError = ErrorType<unknown>

    export const useUploadControllerDeleteFileRecord = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof uploadControllerDeleteFileRecord>>, TError,{id: string}, TContext>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient): UseMutationResult<
        Awaited<ReturnType<typeof uploadControllerDeleteFileRecord>>,
        TError,
        {id: string},
        TContext
      > => {
      return useMutation(getUploadControllerDeleteFileRecordMutationOptions(options), queryClient);
    }

export const getMerchantsControllerSetupUrl = () => {




  return `/api/merchants/setup`
}

export const merchantsControllerSetup = async (merchantSetupDto: MerchantSetupDto, options?: RequestInit): Promise<MerchantResponseDto> => {

  return customFetch<MerchantResponseDto>(getMerchantsControllerSetupUrl(),
  {
    ...options,
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...options?.headers },
    body: JSON.stringify(merchantSetupDto)
  }
);}




export const getMerchantsControllerSetupMutationOptions = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof merchantsControllerSetup>>, TError,{data: BodyType<MerchantSetupDto>}, TContext>, request?: SecondParameter<typeof customFetch>}
): UseMutationOptions<Awaited<ReturnType<typeof merchantsControllerSetup>>, TError,{data: BodyType<MerchantSetupDto>}, TContext> => {

const mutationKey = ['merchantsControllerSetup'];
const {mutation: mutationOptions, request: requestOptions} = options ?
      options.mutation && 'mutationKey' in options.mutation && options.mutation.mutationKey ?
      options
      : {...options, mutation: {...options.mutation, mutationKey}}
      : {mutation: { mutationKey, }, request: undefined};




      const mutationFn: MutationFunction<Awaited<ReturnType<typeof merchantsControllerSetup>>, {data: BodyType<MerchantSetupDto>}> = (props) => {
          const {data} = props ?? {};

          return  merchantsControllerSetup(data,requestOptions)
        }






  return  { mutationFn, ...mutationOptions }}

    export type MerchantsControllerSetupMutationResult = NonNullable<Awaited<ReturnType<typeof merchantsControllerSetup>>>
    export type MerchantsControllerSetupMutationBody = BodyType<MerchantSetupDto>
    export type MerchantsControllerSetupMutationError = ErrorType<unknown>

    export const useMerchantsControllerSetup = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof merchantsControllerSetup>>, TError,{data: BodyType<MerchantSetupDto>}, TContext>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient): UseMutationResult<
        Awaited<ReturnType<typeof merchantsControllerSetup>>,
        TError,
        {data: BodyType<MerchantSetupDto>},
        TContext
      > => {
      return useMutation(getMerchantsControllerSetupMutationOptions(options), queryClient);
    }

export const getMerchantsControllerUpdateMeUrl = () => {




  return `/api/merchants/me`
}

export const merchantsControllerUpdateMe = async (merchantUpdateDto: MerchantUpdateDto, options?: RequestInit): Promise<MerchantResponseDto> => {

  return customFetch<MerchantResponseDto>(getMerchantsControllerUpdateMeUrl(),
  {
    ...options,
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json', ...options?.headers },
    body: JSON.stringify(merchantUpdateDto)
  }
);}




export const getMerchantsControllerUpdateMeMutationOptions = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof merchantsControllerUpdateMe>>, TError,{data: BodyType<MerchantUpdateDto>}, TContext>, request?: SecondParameter<typeof customFetch>}
): UseMutationOptions<Awaited<ReturnType<typeof merchantsControllerUpdateMe>>, TError,{data: BodyType<MerchantUpdateDto>}, TContext> => {

const mutationKey = ['merchantsControllerUpdateMe'];
const {mutation: mutationOptions, request: requestOptions} = options ?
      options.mutation && 'mutationKey' in options.mutation && options.mutation.mutationKey ?
      options
      : {...options, mutation: {...options.mutation, mutationKey}}
      : {mutation: { mutationKey, }, request: undefined};




      const mutationFn: MutationFunction<Awaited<ReturnType<typeof merchantsControllerUpdateMe>>, {data: BodyType<MerchantUpdateDto>}> = (props) => {
          const {data} = props ?? {};

          return  merchantsControllerUpdateMe(data,requestOptions)
        }






  return  { mutationFn, ...mutationOptions }}

    export type MerchantsControllerUpdateMeMutationResult = NonNullable<Awaited<ReturnType<typeof merchantsControllerUpdateMe>>>
    export type MerchantsControllerUpdateMeMutationBody = BodyType<MerchantUpdateDto>
    export type MerchantsControllerUpdateMeMutationError = ErrorType<unknown>

    export const useMerchantsControllerUpdateMe = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof merchantsControllerUpdateMe>>, TError,{data: BodyType<MerchantUpdateDto>}, TContext>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient): UseMutationResult<
        Awaited<ReturnType<typeof merchantsControllerUpdateMe>>,
        TError,
        {data: BodyType<MerchantUpdateDto>},
        TContext
      > => {
      return useMutation(getMerchantsControllerUpdateMeMutationOptions(options), queryClient);
    }

export const getMerchantsControllerFindAllUrl = (params?: MerchantsControllerFindAllParams,) => {
  const normalizedParams = new URLSearchParams();

  Object.entries(params || {}).forEach(([key, value]) => {

    if (value !== undefined) {
      normalizedParams.append(key, value === null ? 'null' : String(value))
    }
  });

  const stringifiedParams = normalizedParams.toString();

  return stringifiedParams.length > 0 ? `/api/merchants?${stringifiedParams}` : `/api/merchants`
}

export const merchantsControllerFindAll = async (params?: MerchantsControllerFindAllParams, options?: RequestInit): Promise<MerchantListResponseDto> => {

  return customFetch<MerchantListResponseDto>(getMerchantsControllerFindAllUrl(params),
  {
    ...options,
    method: 'GET'


  }
);}





export const getMerchantsControllerFindAllQueryKey = (params?: MerchantsControllerFindAllParams,) => {
    return [
    `/api/merchants`, ...(params ? [params] : [])
    ] as const;
    }


export const getMerchantsControllerFindAllQueryOptions = <TData = Awaited<ReturnType<typeof merchantsControllerFindAll>>, TError = ErrorType<unknown>>(params?: MerchantsControllerFindAllParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof merchantsControllerFindAll>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
) => {

const {query: queryOptions, request: requestOptions} = options ?? {};

  const queryKey =  queryOptions?.queryKey ?? getMerchantsControllerFindAllQueryKey(params);



    const queryFn: QueryFunction<Awaited<ReturnType<typeof merchantsControllerFindAll>>> = ({ signal }) => merchantsControllerFindAll(params, { signal, ...requestOptions });





   return  { queryKey, queryFn, ...queryOptions} as UseQueryOptions<Awaited<ReturnType<typeof merchantsControllerFindAll>>, TError, TData> & { queryKey: DataTag<QueryKey, TData, TError> }
}

export type MerchantsControllerFindAllQueryResult = NonNullable<Awaited<ReturnType<typeof merchantsControllerFindAll>>>
export type MerchantsControllerFindAllQueryError = ErrorType<unknown>


export function useMerchantsControllerFindAll<TData = Awaited<ReturnType<typeof merchantsControllerFindAll>>, TError = ErrorType<unknown>>(
 params: undefined |  MerchantsControllerFindAllParams, options: { query:Partial<UseQueryOptions<Awaited<ReturnType<typeof merchantsControllerFindAll>>, TError, TData>> & Pick<
        DefinedInitialDataOptions<
          Awaited<ReturnType<typeof merchantsControllerFindAll>>,
          TError,
          Awaited<ReturnType<typeof merchantsControllerFindAll>>
        > , 'initialData'
      >, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  DefinedUseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }
export function useMerchantsControllerFindAll<TData = Awaited<ReturnType<typeof merchantsControllerFindAll>>, TError = ErrorType<unknown>>(
 params?: MerchantsControllerFindAllParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof merchantsControllerFindAll>>, TError, TData>> & Pick<
        UndefinedInitialDataOptions<
          Awaited<ReturnType<typeof merchantsControllerFindAll>>,
          TError,
          Awaited<ReturnType<typeof merchantsControllerFindAll>>
        > , 'initialData'
      >, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }
export function useMerchantsControllerFindAll<TData = Awaited<ReturnType<typeof merchantsControllerFindAll>>, TError = ErrorType<unknown>>(
 params?: MerchantsControllerFindAllParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof merchantsControllerFindAll>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }

export function useMerchantsControllerFindAll<TData = Awaited<ReturnType<typeof merchantsControllerFindAll>>, TError = ErrorType<unknown>>(
 params?: MerchantsControllerFindAllParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof merchantsControllerFindAll>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
 ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> } {

  const queryOptions = getMerchantsControllerFindAllQueryOptions(params,options)

  const query = useQuery(queryOptions, queryClient) as  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> };

  return { ...query, queryKey: queryOptions.queryKey };
}







export const getMerchantsControllerFindOneUrl = (id: string,) => {




  return `/api/merchants/${id}`
}

export const merchantsControllerFindOne = async (id: string, options?: RequestInit): Promise<MerchantResponseDto> => {

  return customFetch<MerchantResponseDto>(getMerchantsControllerFindOneUrl(id),
  {
    ...options,
    method: 'GET'


  }
);}





export const getMerchantsControllerFindOneQueryKey = (id: string,) => {
    return [
    `/api/merchants/${id}`
    ] as const;
    }


export const getMerchantsControllerFindOneQueryOptions = <TData = Awaited<ReturnType<typeof merchantsControllerFindOne>>, TError = ErrorType<unknown>>(id: string, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof merchantsControllerFindOne>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
) => {

const {query: queryOptions, request: requestOptions} = options ?? {};

  const queryKey =  queryOptions?.queryKey ?? getMerchantsControllerFindOneQueryKey(id);



    const queryFn: QueryFunction<Awaited<ReturnType<typeof merchantsControllerFindOne>>> = ({ signal }) => merchantsControllerFindOne(id, { signal, ...requestOptions });





   return  { queryKey, queryFn, enabled: id !== null && id !== undefined, ...queryOptions} as UseQueryOptions<Awaited<ReturnType<typeof merchantsControllerFindOne>>, TError, TData> & { queryKey: DataTag<QueryKey, TData, TError> }
}

export type MerchantsControllerFindOneQueryResult = NonNullable<Awaited<ReturnType<typeof merchantsControllerFindOne>>>
export type MerchantsControllerFindOneQueryError = ErrorType<unknown>


export function useMerchantsControllerFindOne<TData = Awaited<ReturnType<typeof merchantsControllerFindOne>>, TError = ErrorType<unknown>>(
 id: string, options: { query:Partial<UseQueryOptions<Awaited<ReturnType<typeof merchantsControllerFindOne>>, TError, TData>> & Pick<
        DefinedInitialDataOptions<
          Awaited<ReturnType<typeof merchantsControllerFindOne>>,
          TError,
          Awaited<ReturnType<typeof merchantsControllerFindOne>>
        > , 'initialData'
      >, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  DefinedUseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }
export function useMerchantsControllerFindOne<TData = Awaited<ReturnType<typeof merchantsControllerFindOne>>, TError = ErrorType<unknown>>(
 id: string, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof merchantsControllerFindOne>>, TError, TData>> & Pick<
        UndefinedInitialDataOptions<
          Awaited<ReturnType<typeof merchantsControllerFindOne>>,
          TError,
          Awaited<ReturnType<typeof merchantsControllerFindOne>>
        > , 'initialData'
      >, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }
export function useMerchantsControllerFindOne<TData = Awaited<ReturnType<typeof merchantsControllerFindOne>>, TError = ErrorType<unknown>>(
 id: string, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof merchantsControllerFindOne>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }

export function useMerchantsControllerFindOne<TData = Awaited<ReturnType<typeof merchantsControllerFindOne>>, TError = ErrorType<unknown>>(
 id: string, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof merchantsControllerFindOne>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
 ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> } {

  const queryOptions = getMerchantsControllerFindOneQueryOptions(id,options)

  const query = useQuery(queryOptions, queryClient) as  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> };

  return { ...query, queryKey: queryOptions.queryKey };
}







export const getProductsControllerCreateUrl = () => {




  return `/api/products`
}

export const productsControllerCreate = async (createProductDto: CreateProductDto, options?: RequestInit): Promise<ProductDetailResponseDto> => {

  return customFetch<ProductDetailResponseDto>(getProductsControllerCreateUrl(),
  {
    ...options,
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...options?.headers },
    body: JSON.stringify(createProductDto)
  }
);}




export const getProductsControllerCreateMutationOptions = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof productsControllerCreate>>, TError,{data: BodyType<CreateProductDto>}, TContext>, request?: SecondParameter<typeof customFetch>}
): UseMutationOptions<Awaited<ReturnType<typeof productsControllerCreate>>, TError,{data: BodyType<CreateProductDto>}, TContext> => {

const mutationKey = ['productsControllerCreate'];
const {mutation: mutationOptions, request: requestOptions} = options ?
      options.mutation && 'mutationKey' in options.mutation && options.mutation.mutationKey ?
      options
      : {...options, mutation: {...options.mutation, mutationKey}}
      : {mutation: { mutationKey, }, request: undefined};




      const mutationFn: MutationFunction<Awaited<ReturnType<typeof productsControllerCreate>>, {data: BodyType<CreateProductDto>}> = (props) => {
          const {data} = props ?? {};

          return  productsControllerCreate(data,requestOptions)
        }






  return  { mutationFn, ...mutationOptions }}

    export type ProductsControllerCreateMutationResult = NonNullable<Awaited<ReturnType<typeof productsControllerCreate>>>
    export type ProductsControllerCreateMutationBody = BodyType<CreateProductDto>
    export type ProductsControllerCreateMutationError = ErrorType<unknown>

    export const useProductsControllerCreate = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof productsControllerCreate>>, TError,{data: BodyType<CreateProductDto>}, TContext>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient): UseMutationResult<
        Awaited<ReturnType<typeof productsControllerCreate>>,
        TError,
        {data: BodyType<CreateProductDto>},
        TContext
      > => {
      return useMutation(getProductsControllerCreateMutationOptions(options), queryClient);
    }

export const getProductsControllerFindAllUrl = (params?: ProductsControllerFindAllParams,) => {
  const normalizedParams = new URLSearchParams();

  Object.entries(params || {}).forEach(([key, value]) => {

    if (value !== undefined) {
      normalizedParams.append(key, value === null ? 'null' : String(value))
    }
  });

  const stringifiedParams = normalizedParams.toString();

  return stringifiedParams.length > 0 ? `/api/products?${stringifiedParams}` : `/api/products`
}

export const productsControllerFindAll = async (params?: ProductsControllerFindAllParams, options?: RequestInit): Promise<ProductListResponseDto> => {

  return customFetch<ProductListResponseDto>(getProductsControllerFindAllUrl(params),
  {
    ...options,
    method: 'GET'


  }
);}





export const getProductsControllerFindAllQueryKey = (params?: ProductsControllerFindAllParams,) => {
    return [
    `/api/products`, ...(params ? [params] : [])
    ] as const;
    }


export const getProductsControllerFindAllQueryOptions = <TData = Awaited<ReturnType<typeof productsControllerFindAll>>, TError = ErrorType<unknown>>(params?: ProductsControllerFindAllParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof productsControllerFindAll>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
) => {

const {query: queryOptions, request: requestOptions} = options ?? {};

  const queryKey =  queryOptions?.queryKey ?? getProductsControllerFindAllQueryKey(params);



    const queryFn: QueryFunction<Awaited<ReturnType<typeof productsControllerFindAll>>> = ({ signal }) => productsControllerFindAll(params, { signal, ...requestOptions });





   return  { queryKey, queryFn, ...queryOptions} as UseQueryOptions<Awaited<ReturnType<typeof productsControllerFindAll>>, TError, TData> & { queryKey: DataTag<QueryKey, TData, TError> }
}

export type ProductsControllerFindAllQueryResult = NonNullable<Awaited<ReturnType<typeof productsControllerFindAll>>>
export type ProductsControllerFindAllQueryError = ErrorType<unknown>


export function useProductsControllerFindAll<TData = Awaited<ReturnType<typeof productsControllerFindAll>>, TError = ErrorType<unknown>>(
 params: undefined |  ProductsControllerFindAllParams, options: { query:Partial<UseQueryOptions<Awaited<ReturnType<typeof productsControllerFindAll>>, TError, TData>> & Pick<
        DefinedInitialDataOptions<
          Awaited<ReturnType<typeof productsControllerFindAll>>,
          TError,
          Awaited<ReturnType<typeof productsControllerFindAll>>
        > , 'initialData'
      >, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  DefinedUseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }
export function useProductsControllerFindAll<TData = Awaited<ReturnType<typeof productsControllerFindAll>>, TError = ErrorType<unknown>>(
 params?: ProductsControllerFindAllParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof productsControllerFindAll>>, TError, TData>> & Pick<
        UndefinedInitialDataOptions<
          Awaited<ReturnType<typeof productsControllerFindAll>>,
          TError,
          Awaited<ReturnType<typeof productsControllerFindAll>>
        > , 'initialData'
      >, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }
export function useProductsControllerFindAll<TData = Awaited<ReturnType<typeof productsControllerFindAll>>, TError = ErrorType<unknown>>(
 params?: ProductsControllerFindAllParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof productsControllerFindAll>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }

export function useProductsControllerFindAll<TData = Awaited<ReturnType<typeof productsControllerFindAll>>, TError = ErrorType<unknown>>(
 params?: ProductsControllerFindAllParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof productsControllerFindAll>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
 ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> } {

  const queryOptions = getProductsControllerFindAllQueryOptions(params,options)

  const query = useQuery(queryOptions, queryClient) as  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> };

  return { ...query, queryKey: queryOptions.queryKey };
}







export const getProductsControllerFindMineUrl = (params?: ProductsControllerFindMineParams,) => {
  const normalizedParams = new URLSearchParams();

  Object.entries(params || {}).forEach(([key, value]) => {

    if (value !== undefined) {
      normalizedParams.append(key, value === null ? 'null' : String(value))
    }
  });

  const stringifiedParams = normalizedParams.toString();

  return stringifiedParams.length > 0 ? `/api/products/mine?${stringifiedParams}` : `/api/products/mine`
}

export const productsControllerFindMine = async (params?: ProductsControllerFindMineParams, options?: RequestInit): Promise<ProductListResponseDto> => {

  return customFetch<ProductListResponseDto>(getProductsControllerFindMineUrl(params),
  {
    ...options,
    method: 'GET'


  }
);}





export const getProductsControllerFindMineQueryKey = (params?: ProductsControllerFindMineParams,) => {
    return [
    `/api/products/mine`, ...(params ? [params] : [])
    ] as const;
    }


export const getProductsControllerFindMineQueryOptions = <TData = Awaited<ReturnType<typeof productsControllerFindMine>>, TError = ErrorType<unknown>>(params?: ProductsControllerFindMineParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof productsControllerFindMine>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
) => {

const {query: queryOptions, request: requestOptions} = options ?? {};

  const queryKey =  queryOptions?.queryKey ?? getProductsControllerFindMineQueryKey(params);



    const queryFn: QueryFunction<Awaited<ReturnType<typeof productsControllerFindMine>>> = ({ signal }) => productsControllerFindMine(params, { signal, ...requestOptions });





   return  { queryKey, queryFn, ...queryOptions} as UseQueryOptions<Awaited<ReturnType<typeof productsControllerFindMine>>, TError, TData> & { queryKey: DataTag<QueryKey, TData, TError> }
}

export type ProductsControllerFindMineQueryResult = NonNullable<Awaited<ReturnType<typeof productsControllerFindMine>>>
export type ProductsControllerFindMineQueryError = ErrorType<unknown>


export function useProductsControllerFindMine<TData = Awaited<ReturnType<typeof productsControllerFindMine>>, TError = ErrorType<unknown>>(
 params: undefined |  ProductsControllerFindMineParams, options: { query:Partial<UseQueryOptions<Awaited<ReturnType<typeof productsControllerFindMine>>, TError, TData>> & Pick<
        DefinedInitialDataOptions<
          Awaited<ReturnType<typeof productsControllerFindMine>>,
          TError,
          Awaited<ReturnType<typeof productsControllerFindMine>>
        > , 'initialData'
      >, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  DefinedUseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }
export function useProductsControllerFindMine<TData = Awaited<ReturnType<typeof productsControllerFindMine>>, TError = ErrorType<unknown>>(
 params?: ProductsControllerFindMineParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof productsControllerFindMine>>, TError, TData>> & Pick<
        UndefinedInitialDataOptions<
          Awaited<ReturnType<typeof productsControllerFindMine>>,
          TError,
          Awaited<ReturnType<typeof productsControllerFindMine>>
        > , 'initialData'
      >, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }
export function useProductsControllerFindMine<TData = Awaited<ReturnType<typeof productsControllerFindMine>>, TError = ErrorType<unknown>>(
 params?: ProductsControllerFindMineParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof productsControllerFindMine>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }

export function useProductsControllerFindMine<TData = Awaited<ReturnType<typeof productsControllerFindMine>>, TError = ErrorType<unknown>>(
 params?: ProductsControllerFindMineParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof productsControllerFindMine>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
 ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> } {

  const queryOptions = getProductsControllerFindMineQueryOptions(params,options)

  const query = useQuery(queryOptions, queryClient) as  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> };

  return { ...query, queryKey: queryOptions.queryKey };
}







export const getProductsControllerFindOneUrl = (id: string,) => {




  return `/api/products/${id}`
}

export const productsControllerFindOne = async (id: string, options?: RequestInit): Promise<ProductDetailResponseDto> => {

  return customFetch<ProductDetailResponseDto>(getProductsControllerFindOneUrl(id),
  {
    ...options,
    method: 'GET'


  }
);}





export const getProductsControllerFindOneQueryKey = (id: string,) => {
    return [
    `/api/products/${id}`
    ] as const;
    }


export const getProductsControllerFindOneQueryOptions = <TData = Awaited<ReturnType<typeof productsControllerFindOne>>, TError = ErrorType<unknown>>(id: string, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof productsControllerFindOne>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
) => {

const {query: queryOptions, request: requestOptions} = options ?? {};

  const queryKey =  queryOptions?.queryKey ?? getProductsControllerFindOneQueryKey(id);



    const queryFn: QueryFunction<Awaited<ReturnType<typeof productsControllerFindOne>>> = ({ signal }) => productsControllerFindOne(id, { signal, ...requestOptions });





   return  { queryKey, queryFn, enabled: id !== null && id !== undefined, ...queryOptions} as UseQueryOptions<Awaited<ReturnType<typeof productsControllerFindOne>>, TError, TData> & { queryKey: DataTag<QueryKey, TData, TError> }
}

export type ProductsControllerFindOneQueryResult = NonNullable<Awaited<ReturnType<typeof productsControllerFindOne>>>
export type ProductsControllerFindOneQueryError = ErrorType<unknown>


export function useProductsControllerFindOne<TData = Awaited<ReturnType<typeof productsControllerFindOne>>, TError = ErrorType<unknown>>(
 id: string, options: { query:Partial<UseQueryOptions<Awaited<ReturnType<typeof productsControllerFindOne>>, TError, TData>> & Pick<
        DefinedInitialDataOptions<
          Awaited<ReturnType<typeof productsControllerFindOne>>,
          TError,
          Awaited<ReturnType<typeof productsControllerFindOne>>
        > , 'initialData'
      >, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  DefinedUseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }
export function useProductsControllerFindOne<TData = Awaited<ReturnType<typeof productsControllerFindOne>>, TError = ErrorType<unknown>>(
 id: string, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof productsControllerFindOne>>, TError, TData>> & Pick<
        UndefinedInitialDataOptions<
          Awaited<ReturnType<typeof productsControllerFindOne>>,
          TError,
          Awaited<ReturnType<typeof productsControllerFindOne>>
        > , 'initialData'
      >, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }
export function useProductsControllerFindOne<TData = Awaited<ReturnType<typeof productsControllerFindOne>>, TError = ErrorType<unknown>>(
 id: string, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof productsControllerFindOne>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }

export function useProductsControllerFindOne<TData = Awaited<ReturnType<typeof productsControllerFindOne>>, TError = ErrorType<unknown>>(
 id: string, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof productsControllerFindOne>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
 ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> } {

  const queryOptions = getProductsControllerFindOneQueryOptions(id,options)

  const query = useQuery(queryOptions, queryClient) as  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> };

  return { ...query, queryKey: queryOptions.queryKey };
}







export const getProductsControllerUpdateUrl = (id: string,) => {




  return `/api/products/${id}`
}

export const productsControllerUpdate = async (id: string,
    updateProductDto: UpdateProductDto, options?: RequestInit): Promise<ProductDetailResponseDto> => {

  return customFetch<ProductDetailResponseDto>(getProductsControllerUpdateUrl(id),
  {
    ...options,
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json', ...options?.headers },
    body: JSON.stringify(updateProductDto)
  }
);}




export const getProductsControllerUpdateMutationOptions = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof productsControllerUpdate>>, TError,{id: string;data: BodyType<UpdateProductDto>}, TContext>, request?: SecondParameter<typeof customFetch>}
): UseMutationOptions<Awaited<ReturnType<typeof productsControllerUpdate>>, TError,{id: string;data: BodyType<UpdateProductDto>}, TContext> => {

const mutationKey = ['productsControllerUpdate'];
const {mutation: mutationOptions, request: requestOptions} = options ?
      options.mutation && 'mutationKey' in options.mutation && options.mutation.mutationKey ?
      options
      : {...options, mutation: {...options.mutation, mutationKey}}
      : {mutation: { mutationKey, }, request: undefined};




      const mutationFn: MutationFunction<Awaited<ReturnType<typeof productsControllerUpdate>>, {id: string;data: BodyType<UpdateProductDto>}> = (props) => {
          const {id,data} = props ?? {};

          return  productsControllerUpdate(id,data,requestOptions)
        }






  return  { mutationFn, ...mutationOptions }}

    export type ProductsControllerUpdateMutationResult = NonNullable<Awaited<ReturnType<typeof productsControllerUpdate>>>
    export type ProductsControllerUpdateMutationBody = BodyType<UpdateProductDto>
    export type ProductsControllerUpdateMutationError = ErrorType<unknown>

    export const useProductsControllerUpdate = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof productsControllerUpdate>>, TError,{id: string;data: BodyType<UpdateProductDto>}, TContext>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient): UseMutationResult<
        Awaited<ReturnType<typeof productsControllerUpdate>>,
        TError,
        {id: string;data: BodyType<UpdateProductDto>},
        TContext
      > => {
      return useMutation(getProductsControllerUpdateMutationOptions(options), queryClient);
    }

export const getProductsControllerRemoveUrl = (id: string,) => {




  return `/api/products/${id}`
}

export const productsControllerRemove = async (id: string, options?: RequestInit): Promise<SuccessResponseDto> => {

  return customFetch<SuccessResponseDto>(getProductsControllerRemoveUrl(id),
  {
    ...options,
    method: 'DELETE'


  }
);}




export const getProductsControllerRemoveMutationOptions = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof productsControllerRemove>>, TError,{id: string}, TContext>, request?: SecondParameter<typeof customFetch>}
): UseMutationOptions<Awaited<ReturnType<typeof productsControllerRemove>>, TError,{id: string}, TContext> => {

const mutationKey = ['productsControllerRemove'];
const {mutation: mutationOptions, request: requestOptions} = options ?
      options.mutation && 'mutationKey' in options.mutation && options.mutation.mutationKey ?
      options
      : {...options, mutation: {...options.mutation, mutationKey}}
      : {mutation: { mutationKey, }, request: undefined};




      const mutationFn: MutationFunction<Awaited<ReturnType<typeof productsControllerRemove>>, {id: string}> = (props) => {
          const {id} = props ?? {};

          return  productsControllerRemove(id,requestOptions)
        }






  return  { mutationFn, ...mutationOptions }}

    export type ProductsControllerRemoveMutationResult = NonNullable<Awaited<ReturnType<typeof productsControllerRemove>>>

    export type ProductsControllerRemoveMutationError = ErrorType<unknown>

    export const useProductsControllerRemove = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof productsControllerRemove>>, TError,{id: string}, TContext>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient): UseMutationResult<
        Awaited<ReturnType<typeof productsControllerRemove>>,
        TError,
        {id: string},
        TContext
      > => {
      return useMutation(getProductsControllerRemoveMutationOptions(options), queryClient);
    }

export const getProductsControllerIncrementViewUrl = (id: string,) => {




  return `/api/products/${id}/view`
}

export const productsControllerIncrementView = async (id: string, options?: RequestInit): Promise<ViewCountResponseDto> => {

  return customFetch<ViewCountResponseDto>(getProductsControllerIncrementViewUrl(id),
  {
    ...options,
    method: 'POST'


  }
);}




export const getProductsControllerIncrementViewMutationOptions = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof productsControllerIncrementView>>, TError,{id: string}, TContext>, request?: SecondParameter<typeof customFetch>}
): UseMutationOptions<Awaited<ReturnType<typeof productsControllerIncrementView>>, TError,{id: string}, TContext> => {

const mutationKey = ['productsControllerIncrementView'];
const {mutation: mutationOptions, request: requestOptions} = options ?
      options.mutation && 'mutationKey' in options.mutation && options.mutation.mutationKey ?
      options
      : {...options, mutation: {...options.mutation, mutationKey}}
      : {mutation: { mutationKey, }, request: undefined};




      const mutationFn: MutationFunction<Awaited<ReturnType<typeof productsControllerIncrementView>>, {id: string}> = (props) => {
          const {id} = props ?? {};

          return  productsControllerIncrementView(id,requestOptions)
        }






  return  { mutationFn, ...mutationOptions }}

    export type ProductsControllerIncrementViewMutationResult = NonNullable<Awaited<ReturnType<typeof productsControllerIncrementView>>>

    export type ProductsControllerIncrementViewMutationError = ErrorType<unknown>

    export const useProductsControllerIncrementView = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof productsControllerIncrementView>>, TError,{id: string}, TContext>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient): UseMutationResult<
        Awaited<ReturnType<typeof productsControllerIncrementView>>,
        TError,
        {id: string},
        TContext
      > => {
      return useMutation(getProductsControllerIncrementViewMutationOptions(options), queryClient);
    }

export const getFavoritesControllerAddUrl = (productId: string,) => {




  return `/api/favorites/${productId}`
}

export const favoritesControllerAdd = async (productId: string, options?: RequestInit): Promise<FavoriteSuccessDto> => {

  return customFetch<FavoriteSuccessDto>(getFavoritesControllerAddUrl(productId),
  {
    ...options,
    method: 'POST'


  }
);}




export const getFavoritesControllerAddMutationOptions = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof favoritesControllerAdd>>, TError,{productId: string}, TContext>, request?: SecondParameter<typeof customFetch>}
): UseMutationOptions<Awaited<ReturnType<typeof favoritesControllerAdd>>, TError,{productId: string}, TContext> => {

const mutationKey = ['favoritesControllerAdd'];
const {mutation: mutationOptions, request: requestOptions} = options ?
      options.mutation && 'mutationKey' in options.mutation && options.mutation.mutationKey ?
      options
      : {...options, mutation: {...options.mutation, mutationKey}}
      : {mutation: { mutationKey, }, request: undefined};




      const mutationFn: MutationFunction<Awaited<ReturnType<typeof favoritesControllerAdd>>, {productId: string}> = (props) => {
          const {productId} = props ?? {};

          return  favoritesControllerAdd(productId,requestOptions)
        }






  return  { mutationFn, ...mutationOptions }}

    export type FavoritesControllerAddMutationResult = NonNullable<Awaited<ReturnType<typeof favoritesControllerAdd>>>

    export type FavoritesControllerAddMutationError = ErrorType<unknown>

    export const useFavoritesControllerAdd = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof favoritesControllerAdd>>, TError,{productId: string}, TContext>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient): UseMutationResult<
        Awaited<ReturnType<typeof favoritesControllerAdd>>,
        TError,
        {productId: string},
        TContext
      > => {
      return useMutation(getFavoritesControllerAddMutationOptions(options), queryClient);
    }

export const getFavoritesControllerRemoveUrl = (productId: string,) => {




  return `/api/favorites/${productId}`
}

export const favoritesControllerRemove = async (productId: string, options?: RequestInit): Promise<FavoriteSuccessDto> => {

  return customFetch<FavoriteSuccessDto>(getFavoritesControllerRemoveUrl(productId),
  {
    ...options,
    method: 'DELETE'


  }
);}




export const getFavoritesControllerRemoveMutationOptions = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof favoritesControllerRemove>>, TError,{productId: string}, TContext>, request?: SecondParameter<typeof customFetch>}
): UseMutationOptions<Awaited<ReturnType<typeof favoritesControllerRemove>>, TError,{productId: string}, TContext> => {

const mutationKey = ['favoritesControllerRemove'];
const {mutation: mutationOptions, request: requestOptions} = options ?
      options.mutation && 'mutationKey' in options.mutation && options.mutation.mutationKey ?
      options
      : {...options, mutation: {...options.mutation, mutationKey}}
      : {mutation: { mutationKey, }, request: undefined};




      const mutationFn: MutationFunction<Awaited<ReturnType<typeof favoritesControllerRemove>>, {productId: string}> = (props) => {
          const {productId} = props ?? {};

          return  favoritesControllerRemove(productId,requestOptions)
        }






  return  { mutationFn, ...mutationOptions }}

    export type FavoritesControllerRemoveMutationResult = NonNullable<Awaited<ReturnType<typeof favoritesControllerRemove>>>

    export type FavoritesControllerRemoveMutationError = ErrorType<unknown>

    export const useFavoritesControllerRemove = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof favoritesControllerRemove>>, TError,{productId: string}, TContext>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient): UseMutationResult<
        Awaited<ReturnType<typeof favoritesControllerRemove>>,
        TError,
        {productId: string},
        TContext
      > => {
      return useMutation(getFavoritesControllerRemoveMutationOptions(options), queryClient);
    }

export const getFavoritesControllerFindAllUrl = (params?: FavoritesControllerFindAllParams,) => {
  const normalizedParams = new URLSearchParams();

  Object.entries(params || {}).forEach(([key, value]) => {

    if (value !== undefined) {
      normalizedParams.append(key, value === null ? 'null' : String(value))
    }
  });

  const stringifiedParams = normalizedParams.toString();

  return stringifiedParams.length > 0 ? `/api/favorites?${stringifiedParams}` : `/api/favorites`
}

export const favoritesControllerFindAll = async (params?: FavoritesControllerFindAllParams, options?: RequestInit): Promise<FavoriteListResponseDto> => {

  return customFetch<FavoriteListResponseDto>(getFavoritesControllerFindAllUrl(params),
  {
    ...options,
    method: 'GET'


  }
);}





export const getFavoritesControllerFindAllQueryKey = (params?: FavoritesControllerFindAllParams,) => {
    return [
    `/api/favorites`, ...(params ? [params] : [])
    ] as const;
    }


export const getFavoritesControllerFindAllQueryOptions = <TData = Awaited<ReturnType<typeof favoritesControllerFindAll>>, TError = ErrorType<unknown>>(params?: FavoritesControllerFindAllParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof favoritesControllerFindAll>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
) => {

const {query: queryOptions, request: requestOptions} = options ?? {};

  const queryKey =  queryOptions?.queryKey ?? getFavoritesControllerFindAllQueryKey(params);



    const queryFn: QueryFunction<Awaited<ReturnType<typeof favoritesControllerFindAll>>> = ({ signal }) => favoritesControllerFindAll(params, { signal, ...requestOptions });





   return  { queryKey, queryFn, ...queryOptions} as UseQueryOptions<Awaited<ReturnType<typeof favoritesControllerFindAll>>, TError, TData> & { queryKey: DataTag<QueryKey, TData, TError> }
}

export type FavoritesControllerFindAllQueryResult = NonNullable<Awaited<ReturnType<typeof favoritesControllerFindAll>>>
export type FavoritesControllerFindAllQueryError = ErrorType<unknown>


export function useFavoritesControllerFindAll<TData = Awaited<ReturnType<typeof favoritesControllerFindAll>>, TError = ErrorType<unknown>>(
 params: undefined |  FavoritesControllerFindAllParams, options: { query:Partial<UseQueryOptions<Awaited<ReturnType<typeof favoritesControllerFindAll>>, TError, TData>> & Pick<
        DefinedInitialDataOptions<
          Awaited<ReturnType<typeof favoritesControllerFindAll>>,
          TError,
          Awaited<ReturnType<typeof favoritesControllerFindAll>>
        > , 'initialData'
      >, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  DefinedUseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }
export function useFavoritesControllerFindAll<TData = Awaited<ReturnType<typeof favoritesControllerFindAll>>, TError = ErrorType<unknown>>(
 params?: FavoritesControllerFindAllParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof favoritesControllerFindAll>>, TError, TData>> & Pick<
        UndefinedInitialDataOptions<
          Awaited<ReturnType<typeof favoritesControllerFindAll>>,
          TError,
          Awaited<ReturnType<typeof favoritesControllerFindAll>>
        > , 'initialData'
      >, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }
export function useFavoritesControllerFindAll<TData = Awaited<ReturnType<typeof favoritesControllerFindAll>>, TError = ErrorType<unknown>>(
 params?: FavoritesControllerFindAllParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof favoritesControllerFindAll>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }

export function useFavoritesControllerFindAll<TData = Awaited<ReturnType<typeof favoritesControllerFindAll>>, TError = ErrorType<unknown>>(
 params?: FavoritesControllerFindAllParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof favoritesControllerFindAll>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
 ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> } {

  const queryOptions = getFavoritesControllerFindAllQueryOptions(params,options)

  const query = useQuery(queryOptions, queryClient) as  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> };

  return { ...query, queryKey: queryOptions.queryKey };
}







export const getFollowsControllerFollowUrl = (merchantId: string,) => {




  return `/api/follows/${merchantId}`
}

export const followsControllerFollow = async (merchantId: string, options?: RequestInit): Promise<FollowSuccessDto> => {

  return customFetch<FollowSuccessDto>(getFollowsControllerFollowUrl(merchantId),
  {
    ...options,
    method: 'POST'


  }
);}




export const getFollowsControllerFollowMutationOptions = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof followsControllerFollow>>, TError,{merchantId: string}, TContext>, request?: SecondParameter<typeof customFetch>}
): UseMutationOptions<Awaited<ReturnType<typeof followsControllerFollow>>, TError,{merchantId: string}, TContext> => {

const mutationKey = ['followsControllerFollow'];
const {mutation: mutationOptions, request: requestOptions} = options ?
      options.mutation && 'mutationKey' in options.mutation && options.mutation.mutationKey ?
      options
      : {...options, mutation: {...options.mutation, mutationKey}}
      : {mutation: { mutationKey, }, request: undefined};




      const mutationFn: MutationFunction<Awaited<ReturnType<typeof followsControllerFollow>>, {merchantId: string}> = (props) => {
          const {merchantId} = props ?? {};

          return  followsControllerFollow(merchantId,requestOptions)
        }






  return  { mutationFn, ...mutationOptions }}

    export type FollowsControllerFollowMutationResult = NonNullable<Awaited<ReturnType<typeof followsControllerFollow>>>

    export type FollowsControllerFollowMutationError = ErrorType<unknown>

    export const useFollowsControllerFollow = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof followsControllerFollow>>, TError,{merchantId: string}, TContext>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient): UseMutationResult<
        Awaited<ReturnType<typeof followsControllerFollow>>,
        TError,
        {merchantId: string},
        TContext
      > => {
      return useMutation(getFollowsControllerFollowMutationOptions(options), queryClient);
    }

export const getFollowsControllerUnfollowUrl = (merchantId: string,) => {




  return `/api/follows/${merchantId}`
}

export const followsControllerUnfollow = async (merchantId: string, options?: RequestInit): Promise<FollowSuccessDto> => {

  return customFetch<FollowSuccessDto>(getFollowsControllerUnfollowUrl(merchantId),
  {
    ...options,
    method: 'DELETE'


  }
);}




export const getFollowsControllerUnfollowMutationOptions = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof followsControllerUnfollow>>, TError,{merchantId: string}, TContext>, request?: SecondParameter<typeof customFetch>}
): UseMutationOptions<Awaited<ReturnType<typeof followsControllerUnfollow>>, TError,{merchantId: string}, TContext> => {

const mutationKey = ['followsControllerUnfollow'];
const {mutation: mutationOptions, request: requestOptions} = options ?
      options.mutation && 'mutationKey' in options.mutation && options.mutation.mutationKey ?
      options
      : {...options, mutation: {...options.mutation, mutationKey}}
      : {mutation: { mutationKey, }, request: undefined};




      const mutationFn: MutationFunction<Awaited<ReturnType<typeof followsControllerUnfollow>>, {merchantId: string}> = (props) => {
          const {merchantId} = props ?? {};

          return  followsControllerUnfollow(merchantId,requestOptions)
        }






  return  { mutationFn, ...mutationOptions }}

    export type FollowsControllerUnfollowMutationResult = NonNullable<Awaited<ReturnType<typeof followsControllerUnfollow>>>

    export type FollowsControllerUnfollowMutationError = ErrorType<unknown>

    export const useFollowsControllerUnfollow = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof followsControllerUnfollow>>, TError,{merchantId: string}, TContext>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient): UseMutationResult<
        Awaited<ReturnType<typeof followsControllerUnfollow>>,
        TError,
        {merchantId: string},
        TContext
      > => {
      return useMutation(getFollowsControllerUnfollowMutationOptions(options), queryClient);
    }

export const getFollowsControllerFindAllUrl = (params?: FollowsControllerFindAllParams,) => {
  const normalizedParams = new URLSearchParams();

  Object.entries(params || {}).forEach(([key, value]) => {

    if (value !== undefined) {
      normalizedParams.append(key, value === null ? 'null' : String(value))
    }
  });

  const stringifiedParams = normalizedParams.toString();

  return stringifiedParams.length > 0 ? `/api/follows?${stringifiedParams}` : `/api/follows`
}

export const followsControllerFindAll = async (params?: FollowsControllerFindAllParams, options?: RequestInit): Promise<FollowListResponseDto> => {

  return customFetch<FollowListResponseDto>(getFollowsControllerFindAllUrl(params),
  {
    ...options,
    method: 'GET'


  }
);}





export const getFollowsControllerFindAllQueryKey = (params?: FollowsControllerFindAllParams,) => {
    return [
    `/api/follows`, ...(params ? [params] : [])
    ] as const;
    }


export const getFollowsControllerFindAllQueryOptions = <TData = Awaited<ReturnType<typeof followsControllerFindAll>>, TError = ErrorType<unknown>>(params?: FollowsControllerFindAllParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof followsControllerFindAll>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
) => {

const {query: queryOptions, request: requestOptions} = options ?? {};

  const queryKey =  queryOptions?.queryKey ?? getFollowsControllerFindAllQueryKey(params);



    const queryFn: QueryFunction<Awaited<ReturnType<typeof followsControllerFindAll>>> = ({ signal }) => followsControllerFindAll(params, { signal, ...requestOptions });





   return  { queryKey, queryFn, ...queryOptions} as UseQueryOptions<Awaited<ReturnType<typeof followsControllerFindAll>>, TError, TData> & { queryKey: DataTag<QueryKey, TData, TError> }
}

export type FollowsControllerFindAllQueryResult = NonNullable<Awaited<ReturnType<typeof followsControllerFindAll>>>
export type FollowsControllerFindAllQueryError = ErrorType<unknown>


export function useFollowsControllerFindAll<TData = Awaited<ReturnType<typeof followsControllerFindAll>>, TError = ErrorType<unknown>>(
 params: undefined |  FollowsControllerFindAllParams, options: { query:Partial<UseQueryOptions<Awaited<ReturnType<typeof followsControllerFindAll>>, TError, TData>> & Pick<
        DefinedInitialDataOptions<
          Awaited<ReturnType<typeof followsControllerFindAll>>,
          TError,
          Awaited<ReturnType<typeof followsControllerFindAll>>
        > , 'initialData'
      >, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  DefinedUseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }
export function useFollowsControllerFindAll<TData = Awaited<ReturnType<typeof followsControllerFindAll>>, TError = ErrorType<unknown>>(
 params?: FollowsControllerFindAllParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof followsControllerFindAll>>, TError, TData>> & Pick<
        UndefinedInitialDataOptions<
          Awaited<ReturnType<typeof followsControllerFindAll>>,
          TError,
          Awaited<ReturnType<typeof followsControllerFindAll>>
        > , 'initialData'
      >, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }
export function useFollowsControllerFindAll<TData = Awaited<ReturnType<typeof followsControllerFindAll>>, TError = ErrorType<unknown>>(
 params?: FollowsControllerFindAllParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof followsControllerFindAll>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }

export function useFollowsControllerFindAll<TData = Awaited<ReturnType<typeof followsControllerFindAll>>, TError = ErrorType<unknown>>(
 params?: FollowsControllerFindAllParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof followsControllerFindAll>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
 ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> } {

  const queryOptions = getFollowsControllerFindAllQueryOptions(params,options)

  const query = useQuery(queryOptions, queryClient) as  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> };

  return { ...query, queryKey: queryOptions.queryKey };
}







export const getNotificationsControllerFindAllUrl = (params?: NotificationsControllerFindAllParams,) => {
  const normalizedParams = new URLSearchParams();

  Object.entries(params || {}).forEach(([key, value]) => {

    if (value !== undefined) {
      normalizedParams.append(key, value === null ? 'null' : String(value))
    }
  });

  const stringifiedParams = normalizedParams.toString();

  return stringifiedParams.length > 0 ? `/api/notifications?${stringifiedParams}` : `/api/notifications`
}

export const notificationsControllerFindAll = async (params?: NotificationsControllerFindAllParams, options?: RequestInit): Promise<NotificationListResponseDto> => {

  return customFetch<NotificationListResponseDto>(getNotificationsControllerFindAllUrl(params),
  {
    ...options,
    method: 'GET'


  }
);}





export const getNotificationsControllerFindAllQueryKey = (params?: NotificationsControllerFindAllParams,) => {
    return [
    `/api/notifications`, ...(params ? [params] : [])
    ] as const;
    }


export const getNotificationsControllerFindAllQueryOptions = <TData = Awaited<ReturnType<typeof notificationsControllerFindAll>>, TError = ErrorType<unknown>>(params?: NotificationsControllerFindAllParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof notificationsControllerFindAll>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
) => {

const {query: queryOptions, request: requestOptions} = options ?? {};

  const queryKey =  queryOptions?.queryKey ?? getNotificationsControllerFindAllQueryKey(params);



    const queryFn: QueryFunction<Awaited<ReturnType<typeof notificationsControllerFindAll>>> = ({ signal }) => notificationsControllerFindAll(params, { signal, ...requestOptions });





   return  { queryKey, queryFn, ...queryOptions} as UseQueryOptions<Awaited<ReturnType<typeof notificationsControllerFindAll>>, TError, TData> & { queryKey: DataTag<QueryKey, TData, TError> }
}

export type NotificationsControllerFindAllQueryResult = NonNullable<Awaited<ReturnType<typeof notificationsControllerFindAll>>>
export type NotificationsControllerFindAllQueryError = ErrorType<unknown>


export function useNotificationsControllerFindAll<TData = Awaited<ReturnType<typeof notificationsControllerFindAll>>, TError = ErrorType<unknown>>(
 params: undefined |  NotificationsControllerFindAllParams, options: { query:Partial<UseQueryOptions<Awaited<ReturnType<typeof notificationsControllerFindAll>>, TError, TData>> & Pick<
        DefinedInitialDataOptions<
          Awaited<ReturnType<typeof notificationsControllerFindAll>>,
          TError,
          Awaited<ReturnType<typeof notificationsControllerFindAll>>
        > , 'initialData'
      >, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  DefinedUseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }
export function useNotificationsControllerFindAll<TData = Awaited<ReturnType<typeof notificationsControllerFindAll>>, TError = ErrorType<unknown>>(
 params?: NotificationsControllerFindAllParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof notificationsControllerFindAll>>, TError, TData>> & Pick<
        UndefinedInitialDataOptions<
          Awaited<ReturnType<typeof notificationsControllerFindAll>>,
          TError,
          Awaited<ReturnType<typeof notificationsControllerFindAll>>
        > , 'initialData'
      >, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }
export function useNotificationsControllerFindAll<TData = Awaited<ReturnType<typeof notificationsControllerFindAll>>, TError = ErrorType<unknown>>(
 params?: NotificationsControllerFindAllParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof notificationsControllerFindAll>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }

export function useNotificationsControllerFindAll<TData = Awaited<ReturnType<typeof notificationsControllerFindAll>>, TError = ErrorType<unknown>>(
 params?: NotificationsControllerFindAllParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof notificationsControllerFindAll>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
 ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> } {

  const queryOptions = getNotificationsControllerFindAllQueryOptions(params,options)

  const query = useQuery(queryOptions, queryClient) as  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> };

  return { ...query, queryKey: queryOptions.queryKey };
}







export const getNotificationsControllerMarkReadUrl = (id: string,) => {




  return `/api/notifications/${id}/read`
}

export const notificationsControllerMarkRead = async (id: string, options?: RequestInit): Promise<NotificationReadResponseDto> => {

  return customFetch<NotificationReadResponseDto>(getNotificationsControllerMarkReadUrl(id),
  {
    ...options,
    method: 'PATCH'


  }
);}




export const getNotificationsControllerMarkReadMutationOptions = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof notificationsControllerMarkRead>>, TError,{id: string}, TContext>, request?: SecondParameter<typeof customFetch>}
): UseMutationOptions<Awaited<ReturnType<typeof notificationsControllerMarkRead>>, TError,{id: string}, TContext> => {

const mutationKey = ['notificationsControllerMarkRead'];
const {mutation: mutationOptions, request: requestOptions} = options ?
      options.mutation && 'mutationKey' in options.mutation && options.mutation.mutationKey ?
      options
      : {...options, mutation: {...options.mutation, mutationKey}}
      : {mutation: { mutationKey, }, request: undefined};




      const mutationFn: MutationFunction<Awaited<ReturnType<typeof notificationsControllerMarkRead>>, {id: string}> = (props) => {
          const {id} = props ?? {};

          return  notificationsControllerMarkRead(id,requestOptions)
        }






  return  { mutationFn, ...mutationOptions }}

    export type NotificationsControllerMarkReadMutationResult = NonNullable<Awaited<ReturnType<typeof notificationsControllerMarkRead>>>

    export type NotificationsControllerMarkReadMutationError = ErrorType<unknown>

    export const useNotificationsControllerMarkRead = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof notificationsControllerMarkRead>>, TError,{id: string}, TContext>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient): UseMutationResult<
        Awaited<ReturnType<typeof notificationsControllerMarkRead>>,
        TError,
        {id: string},
        TContext
      > => {
      return useMutation(getNotificationsControllerMarkReadMutationOptions(options), queryClient);
    }

export const getRatingsControllerCreateUrl = (id: string,) => {




  return `/api/merchants/${id}/ratings`
}

export const ratingsControllerCreate = async (id: string,
    createRatingDto: CreateRatingDto, options?: RequestInit): Promise<RatingResponseDto> => {

  return customFetch<RatingResponseDto>(getRatingsControllerCreateUrl(id),
  {
    ...options,
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...options?.headers },
    body: JSON.stringify(createRatingDto)
  }
);}




export const getRatingsControllerCreateMutationOptions = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof ratingsControllerCreate>>, TError,{id: string;data: BodyType<CreateRatingDto>}, TContext>, request?: SecondParameter<typeof customFetch>}
): UseMutationOptions<Awaited<ReturnType<typeof ratingsControllerCreate>>, TError,{id: string;data: BodyType<CreateRatingDto>}, TContext> => {

const mutationKey = ['ratingsControllerCreate'];
const {mutation: mutationOptions, request: requestOptions} = options ?
      options.mutation && 'mutationKey' in options.mutation && options.mutation.mutationKey ?
      options
      : {...options, mutation: {...options.mutation, mutationKey}}
      : {mutation: { mutationKey, }, request: undefined};




      const mutationFn: MutationFunction<Awaited<ReturnType<typeof ratingsControllerCreate>>, {id: string;data: BodyType<CreateRatingDto>}> = (props) => {
          const {id,data} = props ?? {};

          return  ratingsControllerCreate(id,data,requestOptions)
        }






  return  { mutationFn, ...mutationOptions }}

    export type RatingsControllerCreateMutationResult = NonNullable<Awaited<ReturnType<typeof ratingsControllerCreate>>>
    export type RatingsControllerCreateMutationBody = BodyType<CreateRatingDto>
    export type RatingsControllerCreateMutationError = ErrorType<unknown>

    export const useRatingsControllerCreate = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof ratingsControllerCreate>>, TError,{id: string;data: BodyType<CreateRatingDto>}, TContext>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient): UseMutationResult<
        Awaited<ReturnType<typeof ratingsControllerCreate>>,
        TError,
        {id: string;data: BodyType<CreateRatingDto>},
        TContext
      > => {
      return useMutation(getRatingsControllerCreateMutationOptions(options), queryClient);
    }

export const getRatingsControllerFindAllUrl = (id: string,
    params?: RatingsControllerFindAllParams,) => {
  const normalizedParams = new URLSearchParams();

  Object.entries(params || {}).forEach(([key, value]) => {

    if (value !== undefined) {
      normalizedParams.append(key, value === null ? 'null' : String(value))
    }
  });

  const stringifiedParams = normalizedParams.toString();

  return stringifiedParams.length > 0 ? `/api/merchants/${id}/ratings?${stringifiedParams}` : `/api/merchants/${id}/ratings`
}

export const ratingsControllerFindAll = async (id: string,
    params?: RatingsControllerFindAllParams, options?: RequestInit): Promise<RatingListResponseDto> => {

  return customFetch<RatingListResponseDto>(getRatingsControllerFindAllUrl(id,params),
  {
    ...options,
    method: 'GET'


  }
);}





export const getRatingsControllerFindAllQueryKey = (id: string,
    params?: RatingsControllerFindAllParams,) => {
    return [
    `/api/merchants/${id}/ratings`, ...(params ? [params] : [])
    ] as const;
    }


export const getRatingsControllerFindAllQueryOptions = <TData = Awaited<ReturnType<typeof ratingsControllerFindAll>>, TError = ErrorType<unknown>>(id: string,
    params?: RatingsControllerFindAllParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof ratingsControllerFindAll>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
) => {

const {query: queryOptions, request: requestOptions} = options ?? {};

  const queryKey =  queryOptions?.queryKey ?? getRatingsControllerFindAllQueryKey(id,params);



    const queryFn: QueryFunction<Awaited<ReturnType<typeof ratingsControllerFindAll>>> = ({ signal }) => ratingsControllerFindAll(id,params, { signal, ...requestOptions });





   return  { queryKey, queryFn, enabled: id !== null && id !== undefined, ...queryOptions} as UseQueryOptions<Awaited<ReturnType<typeof ratingsControllerFindAll>>, TError, TData> & { queryKey: DataTag<QueryKey, TData, TError> }
}

export type RatingsControllerFindAllQueryResult = NonNullable<Awaited<ReturnType<typeof ratingsControllerFindAll>>>
export type RatingsControllerFindAllQueryError = ErrorType<unknown>


export function useRatingsControllerFindAll<TData = Awaited<ReturnType<typeof ratingsControllerFindAll>>, TError = ErrorType<unknown>>(
 id: string,
    params: undefined |  RatingsControllerFindAllParams, options: { query:Partial<UseQueryOptions<Awaited<ReturnType<typeof ratingsControllerFindAll>>, TError, TData>> & Pick<
        DefinedInitialDataOptions<
          Awaited<ReturnType<typeof ratingsControllerFindAll>>,
          TError,
          Awaited<ReturnType<typeof ratingsControllerFindAll>>
        > , 'initialData'
      >, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  DefinedUseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }
export function useRatingsControllerFindAll<TData = Awaited<ReturnType<typeof ratingsControllerFindAll>>, TError = ErrorType<unknown>>(
 id: string,
    params?: RatingsControllerFindAllParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof ratingsControllerFindAll>>, TError, TData>> & Pick<
        UndefinedInitialDataOptions<
          Awaited<ReturnType<typeof ratingsControllerFindAll>>,
          TError,
          Awaited<ReturnType<typeof ratingsControllerFindAll>>
        > , 'initialData'
      >, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }
export function useRatingsControllerFindAll<TData = Awaited<ReturnType<typeof ratingsControllerFindAll>>, TError = ErrorType<unknown>>(
 id: string,
    params?: RatingsControllerFindAllParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof ratingsControllerFindAll>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }

export function useRatingsControllerFindAll<TData = Awaited<ReturnType<typeof ratingsControllerFindAll>>, TError = ErrorType<unknown>>(
 id: string,
    params?: RatingsControllerFindAllParams, options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof ratingsControllerFindAll>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
 ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> } {

  const queryOptions = getRatingsControllerFindAllQueryOptions(id,params,options)

  const query = useQuery(queryOptions, queryClient) as  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> };

  return { ...query, queryKey: queryOptions.queryKey };
}







export const getReportsControllerCreateUrl = () => {




  return `/api/reports`
}

export const reportsControllerCreate = async (createReportDto: CreateReportDto, options?: RequestInit): Promise<ReportResponseDto> => {

  return customFetch<ReportResponseDto>(getReportsControllerCreateUrl(),
  {
    ...options,
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...options?.headers },
    body: JSON.stringify(createReportDto)
  }
);}




export const getReportsControllerCreateMutationOptions = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof reportsControllerCreate>>, TError,{data: BodyType<CreateReportDto>}, TContext>, request?: SecondParameter<typeof customFetch>}
): UseMutationOptions<Awaited<ReturnType<typeof reportsControllerCreate>>, TError,{data: BodyType<CreateReportDto>}, TContext> => {

const mutationKey = ['reportsControllerCreate'];
const {mutation: mutationOptions, request: requestOptions} = options ?
      options.mutation && 'mutationKey' in options.mutation && options.mutation.mutationKey ?
      options
      : {...options, mutation: {...options.mutation, mutationKey}}
      : {mutation: { mutationKey, }, request: undefined};




      const mutationFn: MutationFunction<Awaited<ReturnType<typeof reportsControllerCreate>>, {data: BodyType<CreateReportDto>}> = (props) => {
          const {data} = props ?? {};

          return  reportsControllerCreate(data,requestOptions)
        }






  return  { mutationFn, ...mutationOptions }}

    export type ReportsControllerCreateMutationResult = NonNullable<Awaited<ReturnType<typeof reportsControllerCreate>>>
    export type ReportsControllerCreateMutationBody = BodyType<CreateReportDto>
    export type ReportsControllerCreateMutationError = ErrorType<unknown>

    export const useReportsControllerCreate = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof reportsControllerCreate>>, TError,{data: BodyType<CreateReportDto>}, TContext>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient): UseMutationResult<
        Awaited<ReturnType<typeof reportsControllerCreate>>,
        TError,
        {data: BodyType<CreateReportDto>},
        TContext
      > => {
      return useMutation(getReportsControllerCreateMutationOptions(options), queryClient);
    }

export const getGeolocationControllerFindNearestUrl = () => {




  return `/api/geolocation/nearest`
}

export const geolocationControllerFindNearest = async (nearestLocationDto: NearestLocationDto, options?: RequestInit): Promise<NearestLocationResponseDto> => {

  return customFetch<NearestLocationResponseDto>(getGeolocationControllerFindNearestUrl(),
  {
    ...options,
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...options?.headers },
    body: JSON.stringify(nearestLocationDto)
  }
);}




export const getGeolocationControllerFindNearestMutationOptions = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof geolocationControllerFindNearest>>, TError,{data: BodyType<NearestLocationDto>}, TContext>, request?: SecondParameter<typeof customFetch>}
): UseMutationOptions<Awaited<ReturnType<typeof geolocationControllerFindNearest>>, TError,{data: BodyType<NearestLocationDto>}, TContext> => {

const mutationKey = ['geolocationControllerFindNearest'];
const {mutation: mutationOptions, request: requestOptions} = options ?
      options.mutation && 'mutationKey' in options.mutation && options.mutation.mutationKey ?
      options
      : {...options, mutation: {...options.mutation, mutationKey}}
      : {mutation: { mutationKey, }, request: undefined};




      const mutationFn: MutationFunction<Awaited<ReturnType<typeof geolocationControllerFindNearest>>, {data: BodyType<NearestLocationDto>}> = (props) => {
          const {data} = props ?? {};

          return  geolocationControllerFindNearest(data,requestOptions)
        }






  return  { mutationFn, ...mutationOptions }}

    export type GeolocationControllerFindNearestMutationResult = NonNullable<Awaited<ReturnType<typeof geolocationControllerFindNearest>>>
    export type GeolocationControllerFindNearestMutationBody = BodyType<NearestLocationDto>
    export type GeolocationControllerFindNearestMutationError = ErrorType<unknown>

    export const useGeolocationControllerFindNearest = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof geolocationControllerFindNearest>>, TError,{data: BodyType<NearestLocationDto>}, TContext>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient): UseMutationResult<
        Awaited<ReturnType<typeof geolocationControllerFindNearest>>,
        TError,
        {data: BodyType<NearestLocationDto>},
        TContext
      > => {
      return useMutation(getGeolocationControllerFindNearestMutationOptions(options), queryClient);
    }

export const getVisitorStatsControllerTrackUrl = () => {




  return `/api/visitor-stats/track`
}

export const visitorStatsControllerTrack = async (trackVisitorDto: TrackVisitorDto, options?: RequestInit): Promise<TrackVisitorResponseDto> => {

  return customFetch<TrackVisitorResponseDto>(getVisitorStatsControllerTrackUrl(),
  {
    ...options,
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...options?.headers },
    body: JSON.stringify(trackVisitorDto)
  }
);}




export const getVisitorStatsControllerTrackMutationOptions = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof visitorStatsControllerTrack>>, TError,{data: BodyType<TrackVisitorDto>}, TContext>, request?: SecondParameter<typeof customFetch>}
): UseMutationOptions<Awaited<ReturnType<typeof visitorStatsControllerTrack>>, TError,{data: BodyType<TrackVisitorDto>}, TContext> => {

const mutationKey = ['visitorStatsControllerTrack'];
const {mutation: mutationOptions, request: requestOptions} = options ?
      options.mutation && 'mutationKey' in options.mutation && options.mutation.mutationKey ?
      options
      : {...options, mutation: {...options.mutation, mutationKey}}
      : {mutation: { mutationKey, }, request: undefined};




      const mutationFn: MutationFunction<Awaited<ReturnType<typeof visitorStatsControllerTrack>>, {data: BodyType<TrackVisitorDto>}> = (props) => {
          const {data} = props ?? {};

          return  visitorStatsControllerTrack(data,requestOptions)
        }






  return  { mutationFn, ...mutationOptions }}

    export type VisitorStatsControllerTrackMutationResult = NonNullable<Awaited<ReturnType<typeof visitorStatsControllerTrack>>>
    export type VisitorStatsControllerTrackMutationBody = BodyType<TrackVisitorDto>
    export type VisitorStatsControllerTrackMutationError = ErrorType<unknown>

    export const useVisitorStatsControllerTrack = <TError = ErrorType<unknown>,
    TContext = unknown>(options?: { mutation?:UseMutationOptions<Awaited<ReturnType<typeof visitorStatsControllerTrack>>, TError,{data: BodyType<TrackVisitorDto>}, TContext>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient): UseMutationResult<
        Awaited<ReturnType<typeof visitorStatsControllerTrack>>,
        TError,
        {data: BodyType<TrackVisitorDto>},
        TContext
      > => {
      return useMutation(getVisitorStatsControllerTrackMutationOptions(options), queryClient);
    }

export const getVisitorStatsControllerSummaryUrl = () => {




  return `/api/visitor-stats/summary`
}

export const visitorStatsControllerSummary = async ( options?: RequestInit): Promise<VisitorStatsSummaryResponseDto> => {

  return customFetch<VisitorStatsSummaryResponseDto>(getVisitorStatsControllerSummaryUrl(),
  {
    ...options,
    method: 'GET'


  }
);}





export const getVisitorStatsControllerSummaryQueryKey = () => {
    return [
    `/api/visitor-stats/summary`
    ] as const;
    }


export const getVisitorStatsControllerSummaryQueryOptions = <TData = Awaited<ReturnType<typeof visitorStatsControllerSummary>>, TError = ErrorType<unknown>>( options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof visitorStatsControllerSummary>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
) => {

const {query: queryOptions, request: requestOptions} = options ?? {};

  const queryKey =  queryOptions?.queryKey ?? getVisitorStatsControllerSummaryQueryKey();



    const queryFn: QueryFunction<Awaited<ReturnType<typeof visitorStatsControllerSummary>>> = ({ signal }) => visitorStatsControllerSummary({ signal, ...requestOptions });





   return  { queryKey, queryFn, ...queryOptions} as UseQueryOptions<Awaited<ReturnType<typeof visitorStatsControllerSummary>>, TError, TData> & { queryKey: DataTag<QueryKey, TData, TError> }
}

export type VisitorStatsControllerSummaryQueryResult = NonNullable<Awaited<ReturnType<typeof visitorStatsControllerSummary>>>
export type VisitorStatsControllerSummaryQueryError = ErrorType<unknown>


export function useVisitorStatsControllerSummary<TData = Awaited<ReturnType<typeof visitorStatsControllerSummary>>, TError = ErrorType<unknown>>(
  options: { query:Partial<UseQueryOptions<Awaited<ReturnType<typeof visitorStatsControllerSummary>>, TError, TData>> & Pick<
        DefinedInitialDataOptions<
          Awaited<ReturnType<typeof visitorStatsControllerSummary>>,
          TError,
          Awaited<ReturnType<typeof visitorStatsControllerSummary>>
        > , 'initialData'
      >, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  DefinedUseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }
export function useVisitorStatsControllerSummary<TData = Awaited<ReturnType<typeof visitorStatsControllerSummary>>, TError = ErrorType<unknown>>(
  options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof visitorStatsControllerSummary>>, TError, TData>> & Pick<
        UndefinedInitialDataOptions<
          Awaited<ReturnType<typeof visitorStatsControllerSummary>>,
          TError,
          Awaited<ReturnType<typeof visitorStatsControllerSummary>>
        > , 'initialData'
      >, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }
export function useVisitorStatsControllerSummary<TData = Awaited<ReturnType<typeof visitorStatsControllerSummary>>, TError = ErrorType<unknown>>(
  options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof visitorStatsControllerSummary>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
  ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> }

export function useVisitorStatsControllerSummary<TData = Awaited<ReturnType<typeof visitorStatsControllerSummary>>, TError = ErrorType<unknown>>(
  options?: { query?:Partial<UseQueryOptions<Awaited<ReturnType<typeof visitorStatsControllerSummary>>, TError, TData>>, request?: SecondParameter<typeof customFetch>}
 , queryClient?: QueryClient
 ):  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> } {

  const queryOptions = getVisitorStatsControllerSummaryQueryOptions(options)

  const query = useQuery(queryOptions, queryClient) as  UseQueryResult<TData, TError> & { queryKey: DataTag<QueryKey, TData, TError> };

  return { ...query, queryKey: queryOptions.queryKey };
}







