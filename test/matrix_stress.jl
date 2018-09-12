@testset "Stress Matrix/Strings (Equality)" begin
    left = ( "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
             * " Ut bibendum a tortor quis suscipit."
             * " Nulla iaculis malesuada arcu, at blandit purus pellentesque sed."
             * " Etiam interdum feugiat quam ut rutrum."
             * " Mauris at leo leo."
             * " Sed sodales sem sit amet facilisis imperdiet."
             * " Nam laoreet, arcu sed dignissim cursus, ex nulla viverra dui, eget mollis lacus libero a mi."
             * " Curabitur mi felis, tincidunt in tempus vitae, consequat non nisl."
             * " Nulla suscipit lacus sed tincidunt tristique."
             * " Cras nunc orci, luctus non fermentum eget, lobortis ultrices velit."
             * " Vestibulum finibus mi sed varius porttitor."
             * " Praesent id lorem quis massa consectetur laoreet."
             * " Etiam ornare augue eu ligula feugiat, sed ornare neque tempus."
             * " Cras maximus leo ante, nec pharetra libero fringilla sit amet." )

    right = ( "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
              * " Ut bibendum a tortor quis suscipit."
              * " Nulla iaculis malesuada arcu, at blandit purus pellentesque sed."
              * " Etiam interdum feugiat quam ut rutrum."
              * " Mauris at leo leo."
              * " Sed sodales sem sit amet facilisis imperdiet."
              * " Nam laoreet, arcu sed dignissim cursus, ex nulla viverra dui, eget mollis lacus libero a mi."
              * " Curabitur mi felis, tincidunt in tempus vitae, consequat non nisl."
              * " Nulla suscipit lacus sed tincidunt tristique."
              * " Cras nunc orci, luctus non fermentum eget, lobortis ultrices velit."
              * " Vestibulum finibus mi sed varius porttitor."
              * " Praesent id lorem quis massa consectetur laoreet."
              * " Etiam ornare augue eu ligula feugiat, sed ornare neque tempus."
              * " Cras maximus leo ante, nec pharetra libero fringilla sit amet." )

    estimated = (length(left) + 1) * (length(right) + 1) * sizeof(Int64)
    allocated = @allocated distance_matrix(left, right)
    @test isapprox(estimated, allocated, atol = 0.05 * estimated)
end

@testset "Stress Matrix/Strings (Inequality)" begin
    left = ( "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
             * " Ut bibendum a tortor quis suscipit."
             * " Nulla iaculis malesuada arcu, at blandit purus pellentesque sed."
             * " Etiam interdum feugiat quam ut rutrum."
             * " Mauris at leo leo."
             * " Sed sodales sem sit amet facilisis imperdiet."
             * " Nam laoreet, arcu sed dignissim cursus, ex nulla viverra dui, eget mollis lacus libero a mi."
             * " Curabitur mi felis, tincidunt in tempus vitae, consequat non nisl."
             * " Nulla suscipit lacus sed tincidunt tristique."
             * " Cras nunc orci, luctus non fermentum eget, lobortis ultrices velit."
             * " Vestibulum finibus mi sed varius porttitor."
             * " Praesent id lorem quis massa consectetur laoreet."
             * " Etiam ornare augue eu ligula feugiat, sed ornare neque tempus."
             * " Cras maximus leo ante, nec pharetra libero fringilla sit amet." )

    right = ( "Sed venenatis, nibh eu hendrerit fermentum, odio sapien imperdiet massa, in sodales lorem mi vitae metus."
              * " Sed nec mi sem."
              * " Cras eu sapien pulvinar, laoreet augue vel, pharetra lacus."
              * " Nam a quam lorem."
              * " Vivamus ornare sem sem, at consectetur mauris tincidunt vitae."
              * " Phasellus eu eros leo."
              * " In scelerisque et ante non varius."
              * " Nullam ante ante, egestas eget lacinia id, commodo quis leo."
              * " Praesent in nunc a odio interdum luctus."
              * " Vestibulum vitae tristique nunc, et tincidunt dolor."
              * " Proin congue lectus ut metus rhoncus, vitae ultricies dolor placerat."
              * " Morbi quam lectus, tincidunt vitae libero condimentum, rhoncus pharetra risus."
              * " Phasellus felis orci, laoreet eget auctor sed, luctus quis nisl."
              * " Vestibulum non rhoncus arcu."
              * " Sed ut vestibulum eros, eget aliquet nibh."
              * " Etiam blandit, orci sit amet hendrerit fringilla, mi purus sagittis velit, et luctus nibh felis at diam." )

    estimated = (length(left) + 1) * (length(right) + 1) * sizeof(Int64)
    allocated = @allocated distance_matrix(left, right)
    @test isapprox(estimated, allocated, atol = 0.05 * estimated)
end
