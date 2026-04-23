//
//  ChipsView.swift
//  Tichu
//
//  Created by Leon on 23.04.2026.
//
// Based on https://www.youtube.com/watch?v=T82izB2XBMA

import SwiftUI

struct ChipsView<Content: View, Tag: Hashable>: View {
    var tags: [Tag]
    var spacing: CGFloat = 10
    var animation: Animation = .easeInOut(duration: 0.2)
    @ViewBuilder var content: (Tag,Bool) -> Content
    var didChangeSelection: ([Tag]) -> ()
    @State private var selectedTags: [Tag] = []
    var body: some View {
        CustomChipLayout(spacing: spacing){
            ForEach(tags,id: \.self){ tag in
                content(tag,selectedTags.contains(tag))
                    .contentShape(.rect)
                    .onTapGesture{
                        withAnimation(animation){
                            if selectedTags.contains(tag){
                                selectedTags.removeAll(where: {$0 == tag})
                            }else{
                                selectedTags.append(tag)
                            }
                        }
                        
                        didChangeSelection(selectedTags)
                    }
            }
        }
    }
}

fileprivate struct CustomChipLayout: Layout{
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        return .init(width: width, height: maxHeight(proposal: proposal, subviews: subviews))
    
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var origin = bounds.origin
        for subview in subviews{
            let fitSize = subview.sizeThatFits(proposal)
            if (origin.x + fitSize.width) > bounds.maxX{
                origin.x = bounds.minX
                origin.y += fitSize.height + spacing
                
                subview.place(at: origin, proposal: proposal)
                origin.x += fitSize.width + spacing
            }else{
                subview.place(at:origin, proposal: proposal)
                origin.x += fitSize.width + spacing
            }
        }
    }
    private func maxHeight(proposal: ProposedViewSize, subviews: Subviews)->CGFloat{
        var origin: CGPoint = .zero
        for subview in subviews{
            let fitSize = subview.sizeThatFits(proposal)
            if (origin.x + fitSize.width) > (proposal.width ?? 0){
                origin.x = 0
                origin.y += fitSize.height + spacing
                
              
                
                origin.x += fitSize.width + spacing
            }else{
                 
                origin.x += fitSize.width + spacing
            }
            if subview == subviews.last{
                origin.y += fitSize.height
            }
        }
        return origin.y
        
    }
    
}


@ViewBuilder
func ChipView(_ tag: String, isSelected: Bool) -> some View {
    
        HStack(spacing: 10){
            Text(tag).font(.callout)
                .foregroundStyle(isSelected ? .white : .primary)
            if isSelected{
                Image(systemName: "checkmark.circle.fill").foregroundStyle(.white)
            }
        }
        .padding(12)
        .glassEffect(isSelected ? .regular.tint(.accentColor).interactive() :.regular.interactive())
        
}

#Preview {
    TestView()
}

