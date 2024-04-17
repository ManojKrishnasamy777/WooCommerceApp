import 'package:e_com/core/core.dart';
import 'package:e_com/feature/auth/controller/auth_ctrl.dart';
import 'package:e_com/feature/cart/controller/carts_ctrl.dart';
import 'package:e_com/feature/user_dash/provider/user_dash_provider.dart';
import 'package:e_com/models/content/product_models.dart';
import 'package:e_com/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProductFabButton extends HookConsumerWidget {
  const ProductFabButton({
    super.key,
    required this.product,
    required this.isProduct,
    required this.selectedVariant,
    required this.campaignId,
    required this.digitalUid,
    required this.onReviewTap,
    required this.isInStock,
    required this.onBuyTap,
  });

  final ProductsData? product;
  final bool isProduct;
  final Function()? onReviewTap;
  final Function()? onBuyTap;
  final String? selectedVariant;
  final String? campaignId;
  final String? digitalUid;
  final bool isInStock;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderedProducts = ref.watch(userDashProvider)?.allOrderedProductsID;
    final isLoggedIn = ref.watch(authCtrlProvider);

    final cartsCtrl = useCallback(() => ref.read(cartCtrlProvider.notifier));

    final canReview = orderedProducts?.contains(product?.uid) ?? false;

    final enableCart = isInStock;
    final isLoading = useState(false);

    return Container(
      color: context.colorTheme.surface,
      child: Row(
        children: [
          if (isLoggedIn)
            if (canReview && onReviewTap != null)
              CircularButton.filled(
                fillColor: context.colorTheme.secondaryContainer,
                margin: defaultPaddingAll.copyWith(right: 0),
                onPressed: onReviewTap,
                iconSize: 22,
                icon: const Icon(Icons.star_border_rounded),
              ),
          Expanded(
            flex: 3,
            child: SubmitButton(
              padding: defaultPaddingAll,
              height: 50,
              isLoading: isLoading.value,
              onPressed: enableCart
                  ? () async {
                      if (isProduct) {
                        isLoading.value = true;
                        await cartsCtrl().addToCart(
                          product: product!,
                          attribute: selectedVariant,
                          cUid: campaignId,
                        );
                      } else {
                        onBuyTap?.call();
                      }
                      isLoading.value = false;
                    }
                  : null,
              icon: const Icon(Icons.shopping_basket_rounded),
              child: Text(
                isProduct
                    ? Translator.addToCart(context)
                    : Translator.chooseAttributes(context),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
