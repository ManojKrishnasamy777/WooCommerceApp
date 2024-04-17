import 'package:collection/collection.dart';
import 'package:e_com/core/core.dart';
import 'package:e_com/feature/auth/controller/auth_ctrl.dart';
import 'package:e_com/feature/cart/controller/carts_ctrl.dart';
import 'package:e_com/feature/cart/view/local/cart_tile.dart';
import 'package:e_com/feature/region_settings/provider/region_provider.dart';
import 'package:e_com/routes/routes.dart';
import 'package:e_com/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CartsView extends HookConsumerWidget {
  const CartsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartList = ref.watch(cartCtrlProvider);
    final cartCtrl = useCallback(() => ref.read(cartCtrlProvider.notifier));
    final local = ref.watch(localeCurrencyStateProvider);

    return cartList.when(
      error: (error, _) =>
          Scaffold(body: ErrorView.reload(error, () => cartCtrl().reload())),
      loading: () => const CartLoading(),
      data: (carts) {
        num subTotal = carts.listData.map((e) => e.total).sum;
        if (!ref.watch(authCtrlProvider)) {
          subTotal = subTotal * (local.currency?.rate ?? 1);
        }
        return PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) {
            if (didPop) {
              return;
            }
            RouteNames.home.goNamed(context);
          },
          child: Scaffold(
            appBar: KAppBar(
              title: Text(
                Translator.shoppingCart(context),
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              height: 120,
              padding: defaultPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(),
                  SpacedText(
                    leftText: Translator.subtotal(context),
                    rightText: subTotal.fromLocal(local),
                    style: context.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  SubmitButton(
                    width: double.infinity,
                    onPressed: subTotal < 1
                        ? null
                        : () => RouteNames.shippingDetails.goNamed(context),
                    child: Text(
                      Translator.submitOrder(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            body: Padding(
              padding: defaultPadding,
              child: RefreshIndicator(
                onRefresh: () => cartCtrl().reload(),
                child: ListViewWithFooter(
                  pagination: carts.pagination,
                  onNext: () => cartCtrl().paginationHandler(true),
                  onPrevious: () => cartCtrl().paginationHandler(false),
                  physics: defaultScrollPhysics,
                  itemCount: carts.length,
                  emptyListWidget:
                      const Center(child: NoItemsAnimationWithFooter()),
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CartTile(cart: carts.listData[index]),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CartLoading extends ConsumerWidget {
  const CartLoading({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        body: ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: defaultPaddingAll,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KShimmer.card(height: 100, width: 100),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FractionallySizedBox(
                        widthFactor: .9,
                        child: KShimmer.card(height: 25),
                      ),
                      const SizedBox(height: 10),
                      FractionallySizedBox(
                        widthFactor: .7,
                        child: KShimmer.card(height: 25),
                      ),
                      const SizedBox(height: 10),
                      FractionallySizedBox(
                        widthFactor: .6,
                        child: KShimmer.card(height: 25),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ));
  }
}
