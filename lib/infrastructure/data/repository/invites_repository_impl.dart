import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';
import '../../../domain/model/invite/invite.dart';
import '../api/invites/dto/invite_dto.dart';
import '../api/invites/invites_api.dart';
import '../api/invites/response/response.dart';
import '../api/mapper/invite_mapper.dart';

@Injectable(as: InvitesRepository)
class InvitesRepositoryImpl implements InvitesRepository {
  InvitesRepositoryImpl(this._invitesApi);

  final InvitesApi _invitesApi;

  @override
  Future<Either<void, List<Invite>>> getInvites() async {
    try {
      final Response<dynamic> response = await _invitesApi.getInvites();
      final GetInvitesResponse getInvitesResponse = GetInvitesResponse.fromJson(
        response.data as List<dynamic>,
      );
      return Right<void, List<Invite>>(
        getInvitesResponse.invites.map(InviteMapper.toDomain).toList(),
      );
    } catch (_) {
      return const Left<void, List<Invite>>(null);
    }
  }

  @override
  Future<Either<void, Invite>> createInvite() async {
    try {
      final Response<dynamic> response = await _invitesApi.createInvite();
      final InviteDTO invite =
          InviteDTO.fromJson(response.data as Map<String, dynamic>);
      return Right<void, Invite>(InviteMapper.toDomain(invite));
    } catch (_) {
      return const Left<void, Invite>(null);
    }
  }

  @override
  Future<bool> applyInvite(String code) async {
    try {
      final Response<dynamic> response = await _invitesApi.applyInvite(code);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
