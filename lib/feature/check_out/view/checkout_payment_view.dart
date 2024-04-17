import 'package:e_com/core/core.dart';
import 'package:e_com/feature/auth/controller/auth_ctrl.dart';
import 'package:e_com/feature/check_out/controller/checkout_ctrl.dart';
import 'package:e_com/feature/check_out/view/local/address_card.dart';
import 'package:e_com/feature/settings/provider/settings_provider.dart';
import 'package:e_com/models/models.dart';
import 'package:e_com/routes/routes.dart';
import 'package:e_com/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CheckoutPaymentView extends HookConsumerWidget {
  const CheckoutPaymentView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkoutCtrl = ref.read(checkoutCtrlProvider.notifier);
    final checkout = ref.watch(checkoutCtrlProvider);
    final config = ref.watch(settingsProvider);
    final isLoggedIn = ref.watch(authCtrlProvider);
    if (config == null) return ErrorView.withScaffold('Settings not found');

    return Scaffold(
      appBar: KAppBar(
        title: Text(Translator.checkout(context)),
        leading: SquareButton.backButton(
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: defaultPadding,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              if (!isLoggedIn) ...[
                Text(
                  Translator.shippingAddress(context),
                  style: context.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                AddressCard(
                  checkout: checkout,
                  onChangeTap: () =>
                      RouteNames.shippingDetails.goNamed(context),
                ),
              ],
              const SizedBox(height: 20),
              Text(
                Translator.paymentMethod(context),
                style: context.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: context.onMobile ? 3 : 6,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: config.paymentMethods.length + 1,
                itemBuilder: (context, index) {
                  final methods = [
                    PaymentData.codPayment,
                    ...config.paymentMethods
                  ];
                  return SelectableCheckCard(
                    header: ClipRRect(
                      borderRadius: defaultRadius,
                      child: methods[index].isCOD
                          ? Container(
                              margin: const EdgeInsets.only(top: 5),
                              decoration: BoxDecoration(
                                borderRadius: defaultRadius,
                                color: context.colorTheme.onErrorContainer,
                              ),
                              height: 60,
                              width: 60,
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Image.asset(
                                  Assets.logo.cod.path,
                                ),
                              ),
                            )
                          : HostedImage.square(
                              methods[index].image,
                              dimension: 60,
                            ),
                    ),
                    title: Text(
                      methods[index].name,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    isSelected: checkout.payment?.uniqueCode ==
                        methods[index].uniqueCode,
                    onTap: () => checkoutCtrl.setPayment(methods[index]),
                  );
                },
              ),
              const SizedBox(height: 80)
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: defaultPaddingAll,
        height: 50,
        width: context.width - 40,
        child: FilledButton(
          onPressed: () {
            if (checkout.payment == null) {
              Toaster.showError(Translator.selectPaymentMethod(context));
              return;
            }
            RouteNames.checkoutSummary.pushNamed(context);
          },
          child: Text(Translator.submitOrder(context)),
        ),
      ),
    );
  }
}

class SelectableCheckCard extends StatelessWidget {
  const SelectableCheckCard({
    super.key,
    this.onTap,
    required this.isSelected,
    this.header,
    required this.title,
    this.subTitle,
  });

  final Function()? onTap;
  final bool isSelected;
  final Widget? header;
  final Widget? title;
  final Widget? subTitle;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: defaultRadius,
              color: context.colorTheme.secondaryContainer.withOpacity(.05),
              border: isSelected
                  ? Border.all(
                      color: context.colorTheme.secondaryContainer,
                      width: 1,
                    )
                  : null,
            ),
            child: Wrap(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (header != null) header!,
                    const SizedBox(height: 10),
                    if (title != null) title!,
                    const SizedBox(height: 5),
                    if (subTitle != null) subTitle!,
                  ],
                ),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              top: 5,
              right: 15,
              child: CircleAvatar(
                radius: 12,
                child: Icon(
                  Icons.done,
                  size: 15,
                  color: context.colorTheme.onError,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
