import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../backend/bloc/signup_request_bloc.dart';
import '../../../../shared/utils/context_extensions.dart';
import '../../../../shared/localization/translation_extension.dart';
import '../view_model/signup_requests_large_screen_view_model.dart';
import '../view_model/signup_requests_small_screen_view_model.dart';

class SignupRequestsLandingPage extends StatefulWidget {
  const SignupRequestsLandingPage({super.key});

  @override
  State<SignupRequestsLandingPage> createState() =>
      _SignupRequestsLandingPageState();
}

class _SignupRequestsLandingPageState extends State<SignupRequestsLandingPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<SignupRequestBloc>();
    if (bloc.state is SignupRequestInitial) {
      bloc.add(FetchAllSignupRequests());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<SignupRequestBloc, SignupRequestState>(
      listener: (context, state) {
        if (state is SignupRequestApproved) {
          context.showSuccessAlert('Richiesta approvata con successo');
        } else if (state is SignupRequestRejected) {
          context.showSuccessAlert('Richiesta rifiutata con successo');
        } else if (state is SignupRequestError) {
          final key = state.translationKey;
          final translated = key != null ? context.tr(key, args: state.translationArgs) : null;
          context.showErrorAlert(
            translated != null && translated != key ? translated : state.message,
          );
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth <= 1000;
          if (isSmallScreen) {
            return const SignupRequestsSmallScreenViewModel();
          } else {
            return const SignupRequestsLargeScreenViewModel();
          }
        },
      ),
    );
  }
}
