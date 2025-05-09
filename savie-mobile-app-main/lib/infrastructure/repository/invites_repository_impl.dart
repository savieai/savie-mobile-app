import 'package:either_dart/either.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../domain/domain.dart';
import '../infrastructure.dart';

@Injectable(as: InvitesRepository)
class InvitesRepositoryImpl implements InvitesRepository {
  InvitesRepositoryImpl(this._invitesApi);

  final InvitesApi _invitesApi;

  @override
  Future<Either<void, List<Invite>>> getInvites() async {
    try {
      final HttpResponse<GetInvitesResponse> response =
          await _invitesApi.getInvites();
      return Right<void, List<Invite>>(
        response.data.map(InviteMapper.toDomain).toList(),
      );
    } catch (_) {
      return const Left<void, List<Invite>>(null);
    }
  }

  @override
  Future<Either<void, Invite>> createInvite() async {
    try {
      final HttpResponse<CreateInviteResponse> response =
          await _invitesApi.createInvite();
      return Right<void, Invite>(InviteMapper.toDomain(response.data));
    } catch (_) {
      return const Left<void, Invite>(null);
    }
  }

  @override
  Future<bool> applyInvite(String code) async {
    try {
      final HttpResponse<void> response = await _invitesApi.applyInvite(code);
      return response.response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
