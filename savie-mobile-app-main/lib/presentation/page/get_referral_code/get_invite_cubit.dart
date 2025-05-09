import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../application/use_case/invites/get_invites_use_case.dart';
import '../../../domain/model/invite.dart';

part 'get_invite_cubit.freezed.dart';

@Injectable()
class GetInviteCubit extends Cubit<GetInviteState> {
  GetInviteCubit(
    this._getInvitesUseCase,
  ) : super(const GetInviteState.fetching()) {
    _getInvitesUseCase.execute().then((Either<void, List<Invite>> result) {
      if (isClosed) {
        return;
      }

      result.either(
        (_) => emit(const GetInviteState.error()),
        (List<Invite> invites) => emit(
          GetInviteState.fetched(
            code: invites.firstAvailableOrNull?.code,
            numOfAvailable: invites.numOfAvailable,
          ),
        ),
      );
    });
  }

  final GetInvitesUseCase _getInvitesUseCase;
}

@freezed
class GetInviteState with _$GetInviteState {
  const factory GetInviteState.fetching() = _Fetching;
  const factory GetInviteState.fetched({
    required String? code,
    required int numOfAvailable,
  }) = _Fetched;
  const factory GetInviteState.error() = _Error;
}
