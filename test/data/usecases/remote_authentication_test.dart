import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fordev/data/http/http.dart';
import 'package:fordev/data/http/http_error.dart';
import 'package:fordev/data/usecases/use_cases.dart';
import 'package:fordev/domain/helpers/helpers.dart';
import 'package:fordev/domain/useCases/authentication.dart';
import 'package:mockito/mockito.dart';

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  RemoteAuthentication? sut;
  HttpClientSpy? httpClient;
  String? url;
  AuthenticationParams? params;

  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClient!, url: url!);
    params = AuthenticationParams(
      email: faker.internet.email(),
      secret: faker.internet.password(),
    );
  });

  test('should call HttpClient with correct values', () async {
    await sut!.auth(params!);

    verify(httpClient!.request(
      url: url!,
      method: 'post',
      body: {
        'email': params!.email,
        'password': params!.secret,
      },
    ));
  });

  test('should throw UnexpectedError if Httpclient returns 400', () async {
    when(httpClient!.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      body: anyNamed('body'),
    )).thenThrow(HttpError.badRequest);

    final future = sut!.auth(params!);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('should throw UnexpectedError if Httpclient returns 404', () async {
    when(httpClient!.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      body: anyNamed('body'),
    )).thenThrow(HttpError.notFound);

    final future = sut!.auth(params!);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('should throw UnexpectedError if Httpclient returns 500', () async {
    when(httpClient!.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      body: anyNamed('body'),
    )).thenThrow(HttpError.serverError);

    final future = sut!.auth(params!);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('should throw InvalidCrendetioalsError if Httpclient returns 401',
      () async {
    when(httpClient!.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      body: anyNamed('body'),
    )).thenThrow(HttpError.unauthorized);

    final future = sut!.auth(params!);

    expect(future, throwsA(DomainError.invalidCredential));
  });
}
