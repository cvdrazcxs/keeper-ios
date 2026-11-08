import SwiftUI
import TKUIKit

struct FakeBalanceEditorScreen: View {
    @ObservedObject var viewModel: FakeBalanceEditorViewModel

    var body: some View {
        VStack(spacing: 0) {
            DefaultModalCardHeader(
                config: .push(
                    title: viewModel.title,
                    onBack: {
                        viewModel.didRequestClose?()
                    }
                )
            )

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    sectionTitle(FakeBalanceStrings.tokenSectionTitle)
                    tokenList

                    sectionTitle(FakeBalanceStrings.amountSectionTitle)
                        .padding(.top, 20)
                    amountField

                    Text(FakeBalanceStrings.caption)
                        .font(.system(size: 13))
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                        .padding(.top, 8)
                        .fixedSize(horizontal: false, vertical: true)

                    confirmButton
                        .padding(.top, 24)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(UIColor.systemGroupedBackground))
        .ignoresSafeArea(.all, edges: .bottom)
        .task {
            viewModel.reload()
        }
    }
}

private extension FakeBalanceEditorScreen {
    func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color(UIColor.secondaryLabel))
            .padding(.bottom, 8)
    }

    var tokenList: some View {
        VStack(spacing: 0) {
            if let external = viewModel.externalOption {
                tokenRow(external)
                Divider()
                    .padding(.leading, 60)
            }
            ForEach(Array(viewModel.tokenOptions.enumerated()), id: \.element.id) { _, option in
                Button {
                    viewModel.select(option)
                } label: {
                    tokenRow(option)
                }
                .buttonStyle(.plain)
            }
            Button {
                viewModel.didRequestOpenCatalogPicker?()
            } label: {
                HStack(spacing: 10) {
                    SwiftUI.Image(systemName: "magnifyingglass")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                    Text(FakeBalanceStrings.allCoinsButton)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.accentColor)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    func tokenRow(_ option: FakeBalanceEditorViewModel.TokenOption) -> some View {
        HStack(spacing: 12) {
            tokenIcon(option)

            VStack(alignment: .leading, spacing: 2) {
                Text(option.symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(UIColor.label))
                Text(option.name)
                    .font(.system(size: 13))
                    .foregroundStyle(Color(UIColor.secondaryLabel))
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            if viewModel.selectedTokenID == option.id || viewModel.externalOption?.id == option.id {
                SwiftUI.Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.accentColor)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }

    func tokenIcon(_ option: FakeBalanceEditorViewModel.TokenOption) -> some View {
        Group {
            if let imageURL = option.imageURL {
                AsyncImage(url: imageURL) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        tokenPlaceholder(option)
                    }
                }
            } else {
                tokenPlaceholder(option)
            }
        }
        .frame(width: 36, height: 36)
        .clipShape(Circle())
        .clipped()
    }

    func tokenPlaceholder(_ option: FakeBalanceEditorViewModel.TokenOption) -> some View {
        ZStack {
            Color(UIColor.systemGray5)
            Text(String(option.symbol.prefix(1)).uppercased())
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color(UIColor.secondaryLabel))
        }
    }

    var amountField: some View {
        HStack(spacing: 8) {
            TextField(FakeBalanceStrings.amountPlaceholder, text: $viewModel.amountText)
                .keyboardType(.decimalPad)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color(UIColor.label))
                .autocorrectionDisabled(true)

            if !viewModel.selectedSymbol.isEmpty {
                Text(viewModel.selectedSymbol)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(UIColor.secondaryLabel))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    var confirmButton: some View {
        Button {
            viewModel.confirm()
        } label: {
            Text(FakeBalanceStrings.confirm)
                .font(.system(size: 17, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(viewModel.canConfirm ? Color.accentColor : Color(UIColor.systemGray4))
                .foregroundStyle(viewModel.canConfirm ? Color.white : Color(UIColor.systemGray))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .disabled(!viewModel.canConfirm)
    }
}
