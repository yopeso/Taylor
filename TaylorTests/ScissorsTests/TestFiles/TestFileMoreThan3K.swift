import Accelerate

// MARK: Sum

public func sum(x: [Float]) -> Float {
    var result: Float = 0.0
    vDSP_sve(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

public func sum(x: [Double]) -> Double {
    var result: Double = 0.0
    vDSP_sveD(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

// MARK: Sum of Absolute Values

public func asum(x: [Float]) -> Float {
    return cblas_sasum(Int32(x.count), x, 1)
}

public func asum(x: [Double]) -> Double {
    return cblas_dasum(Int32(x.count), x, 1)
}

// MARK: Maximum

public func max(x: [Float]) -> Float {
    var result: Float = 0.0
    vDSP_maxv(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

public func max(x: [Double]) -> Double {
    var result: Double = 0.0
    vDSP_maxvD(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

// MARK: Minimum

public func min(x: [Float]) -> Float {
    var result: Float = 0.0
    vDSP_minv(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

public func min(x: [Double]) -> Double {
    var result: Double = 0.0
    vDSP_minvD(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

// MARK: Mean

public func mean(x: [Float]) -> Float {
    var result: Float = 0.0
    vDSP_meanv(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

public func mean(x: [Double]) -> Double {
    var result: Double = 0.0
    vDSP_meanvD(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

// MARK: Mean Magnitude

public func meamg(x: [Float]) -> Float {
    var result: Float = 0.0
    vDSP_meamgv(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

public func meamg(x: [Double]) -> Double {
    var result: Double = 0.0
    vDSP_meamgvD(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

// MARK: Mean Square Value

public func measq(x: [Float]) -> Float {
    var result: Float = 0.0
    vDSP_measqv(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

public func measq(x: [Double]) -> Double {
    var result: Double = 0.0
    vDSP_measqvD(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

// MARK: Add

public func add(x: [Float], y: [Float]) -> [Float] {
    var results = [Float](y)
    cblas_saxpy(Int32(x.count), 1.0, x, 1, &results, 1)
    
    return results
}

public func add(x: [Double], y: [Double]) -> [Double] {
    var results = [Double](y)
    cblas_daxpy(Int32(x.count), 1.0, x, 1, &results, 1)
    
    return results
}

// MARK: Multiply

public func mul(x: [Float], y: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vDSP_vmul(x, 1, y, 1, &results, 1, vDSP_Length(x.count))
    
    return results
}

public func mul(x: [Double], y: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vDSP_vmulD(x, 1, y, 1, &results, 1, vDSP_Length(x.count))
    
    return results
}

// MARK: Divide

public func div(x: [Float], y: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvdivf(&results, x, y, [Int32(x.count)])
    
    return results
}

public func div(x: [Double], y: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvdiv(&results, x, y, [Int32(x.count)])
    
    return results
}

// MARK: Modulo

public func mod(x: [Float], y: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvfmodf(&results, x, y, [Int32(x.count)])
    
    return results
}

public func mod(x: [Double], y: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvfmod(&results, x, y, [Int32(x.count)])
    
    return results
}

// MARK: Remainder

public func remainder(x: [Float], y: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvremainderf(&results, x, y, [Int32(x.count)])
    
    return results
}

public func remainder(x: [Double], y: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvremainder(&results, x, y, [Int32(x.count)])
    
    return results
}

// MARK: Square Root

public func sqrt(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvsqrtf(&results, x, [Int32(x.count)])
    
    return results
}

public func sqrt(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvsqrt(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Dot Product

public func dot(x: [Float], y: [Float]) -> Float {
    precondition(x.count == y.count, "Vectors must have equal count")
    
    var result: Float = 0.0
    vDSP_dotpr(x, 1, y, 1, &result, vDSP_Length(x.count))
    
    return result
}


public func dot(x: [Double], y: [Double]) -> Double {
    precondition(x.count == y.count, "Vectors must have equal count")
    
    var result: Double = 0.0
    vDSP_dotprD(x, 1, y, 1, &result, vDSP_Length(x.count))
    
    return result
}

// MARK: - Operators

func + (lhs: [Float], rhs: [Float]) -> [Float] {
    return add(lhs, rhs)
}

func + (lhs: [Double], rhs: [Double]) -> [Double] {
    return add(lhs, rhs)
}

func + (lhs: [Float], rhs: Float) -> [Float] {
    return add(lhs, [Float](count: lhs.count, repeatedValue: rhs))
}

func + (lhs: [Double], rhs: Double) -> [Double] {
    return add(lhs, [Double](count: lhs.count, repeatedValue: rhs))
}

func / (lhs: [Float], rhs: [Float]) -> [Float] {
    return div(lhs, rhs)
}

func / (lhs: [Double], rhs: [Double]) -> [Double] {
    return div(lhs, rhs)
}

func / (lhs: [Float], rhs: Float) -> [Float] {
    return div(lhs, [Float](count: lhs.count, repeatedValue: rhs))
}

func / (lhs: [Double], rhs: Double) -> [Double] {
    return div(lhs, [Double](count: lhs.count, repeatedValue: rhs))
}

func * (lhs: [Float], rhs: [Float]) -> [Float] {
    return mul(lhs, rhs)
}

func * (lhs: [Double], rhs: [Double]) -> [Double] {
    return mul(lhs, rhs)
}

func * (lhs: [Float], rhs: Float) -> [Float] {
    return mul(lhs, [Float](count: lhs.count, repeatedValue: rhs))
}

func * (lhs: [Double], rhs: Double) -> [Double] {
    return mul(lhs, [Double](count: lhs.count, repeatedValue: rhs))
}

func % (lhs: [Float], rhs: [Float]) -> [Float] {
    return mod(lhs, rhs)
}

func % (lhs: [Double], rhs: [Double]) -> [Double] {
    return mod(lhs, rhs)
}

func % (lhs: [Float], rhs: Float) -> [Float] {
    return mod(lhs, [Float](count: lhs.count, repeatedValue: rhs))
}

func % (lhs: [Double], rhs: Double) -> [Double] {
    return mod(lhs, [Double](count: lhs.count, repeatedValue: rhs))
}

infix operator • {}
func • (lhs: [Double], rhs: [Double]) -> Double {
    return dot(lhs, rhs)
}

func • (lhs: [Float], rhs: [Float]) -> Float {
    return dot(lhs, rhs)
}


// MARK: Absolute Value

public func abs(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvfabs(&results, x, [Int32(x.count)])
    
    return results
}

public func abs(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvfabsf(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Ceiling

public func ceil(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvceilf(&results, x, [Int32(x.count)])
    
    return results
}

public func ceil(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvceil(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Clip

public func clip(x: [Float], low: Float, high: Float) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0), y = low, z = high
    vDSP_vclip(x, 1, &y, &z, &results, 1, vDSP_Length(x.count))
    
    return results
}

public func clip(x: [Double], low: Double, high: Double) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0), y = low, z = high
    vDSP_vclipD(x, 1, &y, &z, &results, 1, vDSP_Length(x.count))
    
    return results
}

// MARK: Copy Sign

public func copysign(sign: [Float], magnitude: [Float]) -> [Float] {
    var results = [Float](count: sign.count, repeatedValue: 0.0)
    vvcopysignf(&results, magnitude, sign, [Int32(sign.count)])
    
    return results
}

public func copysign(sign: [Double], magnitude: [Double]) -> [Double] {
    var results = [Double](count: sign.count, repeatedValue: 0.0)
    vvcopysign(&results, magnitude, sign, [Int32(sign.count)])
    
    return results
}

// MARK: Floor

public func floor(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvfloorf(&results, x, [Int32(x.count)])
    
    return results
}

public func floor(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvfloor(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Negate

public func neg(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vDSP_vneg(x, 1, &results, 1, vDSP_Length(x.count))
    
    return results
}

public func neg(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vDSP_vnegD(x, 1, &results, 1, vDSP_Length(x.count))
    
    return results
}

// MARK: Reciprocal

public func rec(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvrecf(&results, x, [Int32(x.count)])
    
    return results
}

public func rec(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvrec(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Round

public func round(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvnintf(&results, x, [Int32(x.count)])
    
    return results
}

public func round(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvnint(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Threshold

public func threshold(x: [Float], low: Float) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0), y = low
    vDSP_vthr(x, 1, &y, &results, 1, vDSP_Length(x.count))
    
    return results
}

public func threshold(x: [Double], low: Double) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0), y = low
    vDSP_vthrD(x, 1, &y, &results, 1, vDSP_Length(x.count))
    
    return results
}

// MARK: Truncate

public func trunc(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvintf(&results, x, [Int32(x.count)])
    
    return results
}

public func trunc(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvint(&results, x, [Int32(x.count)])
    
    return results
}
// MARK: Exponentiation

public func exp(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvexpf(&results, x, [Int32(x.count)])
    
    return results
}

public func exp(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvexp(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Square Exponentiation

public func exp2(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvexp2f(&results, x, [Int32(x.count)])
    
    return results
}

public func exp2(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvexp2(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Natural Logarithm

public func log(x: [Float]) -> [Float] {
    var results = [Float](x)
    vvlogf(&results, x, [Int32(x.count)])
    
    return results
}

public func log(x: [Double]) -> [Double] {
    var results = [Double](x)
    vvlog(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Base-2 Logarithm

public func log2(x: [Float]) -> [Float] {
    var results = [Float](x)
    vvlog2f(&results, x, [Int32(x.count)])
    
    return results
}

public func log2(x: [Double]) -> [Double] {
    var results = [Double](x)
    vvlog2(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Base-10 Logarithm

public func log10(x: [Float]) -> [Float] {
    var results = [Float](x)
    vvlog10f(&results, x, [Int32(x.count)])
    
    return results
}

public func log10(x: [Double]) -> [Double] {
    var results = [Double](x)
    vvlog10(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Logarithmic Exponentiation

public func logb(x: [Float]) -> [Float] {
    var results = [Float](x)
    vvlogbf(&results, x, [Int32(x.count)])
    
    return results
}

public func logb(x: [Double]) -> [Double] {
    var results = [Double](x)
    vvlogb(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Fast Fourier Transform

public func fft(input: [Float]) -> [Float] {
    var real = [Float](input)
    var imaginary = [Float](count: input.count, repeatedValue: 0.0)
    var splitComplex = DSPSplitComplex(realp: &real, imagp: &imaginary)
    
    let length = vDSP_Length(floor(log2(Float(input.count))))
    let radix = FFTRadix(kFFTRadix2)
    let weights = vDSP_create_fftsetup(length, radix)
    vDSP_fft_zip(weights, &splitComplex, 1, length, FFTDirection(FFT_FORWARD))
    
    var magnitudes = [Float](count: input.count, repeatedValue: 0.0)
    vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(input.count))
    
    var normalizedMagnitudes = [Float](count: input.count, repeatedValue: 0.0)
    vDSP_vsmul(sqrt(magnitudes), 1, [2.0 / Float(input.count)], &normalizedMagnitudes, 1, vDSP_Length(input.count))
    
    vDSP_destroy_fftsetup(weights)
    
    return normalizedMagnitudes
}

public func fft(input: [Double]) -> [Double] {
    var real = [Double](input)
    var imaginary = [Double](count: input.count, repeatedValue: 0.0)
    var splitComplex = DSPDoubleSplitComplex(realp: &real, imagp: &imaginary)
    
    let length = vDSP_Length(floor(log2(Float(input.count))))
    let radix = FFTRadix(kFFTRadix2)
    let weights = vDSP_create_fftsetupD(length, radix)
    vDSP_fft_zipD(weights, &splitComplex, 1, length, FFTDirection(FFT_FORWARD))
    
    var magnitudes = [Double](count: input.count, repeatedValue: 0.0)
    vDSP_zvmagsD(&splitComplex, 1, &magnitudes, 1, vDSP_Length(input.count))
    
    var normalizedMagnitudes = [Double](count: input.count, repeatedValue: 0.0)
    vDSP_vsmulD(sqrt(magnitudes), 1, [2.0 / Double(input.count)], &normalizedMagnitudes, 1, vDSP_Length(input.count))
    
    vDSP_destroy_fftsetupD(weights)
    
    return normalizedMagnitudes
}

// MARK: Hyperbolic Sine

public func sinh(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvsinhf(&results, x, [Int32(x.count)])
    
    return results
}

public func sinh(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvsinh(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Hyperbolic Cosine

public func cosh(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvcoshf(&results, x, [Int32(x.count)])
    
    return results
}

public func cosh(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvcosh(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Hyperbolic Tangent

public func tanh(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvtanhf(&results, x, [Int32(x.count)])
    
    return results
}

public func tanh(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvtanh(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Inverse Hyperbolic Sine

public func asinh(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvasinhf(&results, x, [Int32(x.count)])
    
    return results
}

public func asinh(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvasinh(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Inverse Hyperbolic Cosine

public func acosh(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvacoshf(&results, x, [Int32(x.count)])
    
    return results
}

public func acosh(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvacosh(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Inverse Hyperbolic Tangent

public func atanh(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvatanhf(&results, x, [Int32(x.count)])
    
    return results
}

public func atanh(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvatanh(&results, x, [Int32(x.count)])
    
    return results
}

public struct Matrix<T where T: FloatingPointType, T: FloatLiteralConvertible> {
    typealias Element = T
    
    let rows: Int
    let columns: Int
    var grid: [Element]
    
    public init(rows: Int, columns: Int, repeatedValue: Element) {
        self.rows = rows
        self.columns = columns
        
        self.grid = [Element](count: rows * columns, repeatedValue: repeatedValue)
    }
    
    public init(_ contents: [[Element]]) {
        let m: Int = contents.count
        let n: Int = contents[0].count
        let repeatedValue: Element = 0.0
        
        self.init(rows: m, columns: n, repeatedValue: repeatedValue)
        
        for (i, row) in enumerate(contents) {
            grid.replaceRange(i*n..<i*n+min(m, row.count), with: row)
        }
    }
    
    public subscript(row: Int, column: Int) -> Element {
        get {
            assert(indexIsValidForRow(row, column: column))
            return grid[(row * columns) + column]
        }
        
        set {
            assert(indexIsValidForRow(row, column: column))
            grid[(row * columns) + column] = newValue
        }
    }
    
    private func indexIsValidForRow(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
}

// MARK: - Printable

extension Matrix: Printable {
    public var description: String {
        var description = ""
        
        for i in 0..<rows {
            let contents = join("\t", map(0..<columns){"\(self[i, $0])"})
            
            switch (i, rows) {
            case (0, 1):
                description += "(\t\(contents)\t)"
            case (0, _):
                description += "⎛\t\(contents)\t⎞"
            case (rows - 1, _):
                description += "⎝\t\(contents)\t⎠"
            default:
                description += "⎜\t\(contents)\t⎥"
            }
            
            description += "\n"
        }
        
        return description
    }
}

// MARK: - SequenceType

extension Matrix: SequenceType {
    public func generate() -> GeneratorOf<ArraySlice<Element>> {
        let endIndex = rows * columns
        var nextRowStartIndex = 0
        
        return GeneratorOf<ArraySlice<Element>> {
            if nextRowStartIndex == endIndex {
                return nil
            }
            
            let currentRowStartIndex = nextRowStartIndex
            nextRowStartIndex += self.columns
            
            return self.grid[currentRowStartIndex..<nextRowStartIndex]
        }
    }
}

// MARK: -

public func add(x: Matrix<Float>, y: Matrix<Float>) -> Matrix<Float> {
    precondition(x.rows == y.rows && x.columns == y.columns, "Matrix dimensions not compatible with addition")
    
    var results = y
    cblas_saxpy(Int32(x.grid.count), 1.0, x.grid, 1, &(results.grid), 1)
    
    return results
}

public func add(x: Matrix<Double>, y: Matrix<Double>) -> Matrix<Double> {
    precondition(x.rows == y.rows && x.columns == y.columns, "Matrix dimensions not compatible with addition")
    
    var results = y
    cblas_daxpy(Int32(x.grid.count), 1.0, x.grid, 1, &(results.grid), 1)
    
    return results
}

public func mul(alpha: Float, x: Matrix<Float>) -> Matrix<Float> {
    var results = x
    cblas_sscal(Int32(x.grid.count), alpha, &(results.grid), 1)
    
    return results
}

public func mul(alpha: Double, x: Matrix<Double>) -> Matrix<Double> {
    var results = x
    cblas_dscal(Int32(x.grid.count), alpha, &(results.grid), 1)
    
    return results
}

public func mul(x: Matrix<Float>, y: Matrix<Float>) -> Matrix<Float> {
    precondition(x.columns == y.rows, "Matrix dimensions not compatible with multiplication")
    
    var results = Matrix<Float>(rows: x.rows, columns: y.columns, repeatedValue: 0.0)
    cblas_sgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans, Int32(x.rows), Int32(y.columns), Int32(x.columns), 1.0, x.grid, Int32(x.columns), y.grid, Int32(y.columns), 0.0, &(results.grid), Int32(results.columns))
    
    return results
}

public func mul(x: Matrix<Double>, y: Matrix<Double>) -> Matrix<Double> {
    precondition(x.columns == y.rows, "Matrix dimensions not compatible with multiplication")
    
    var results = Matrix<Double>(rows: x.rows, columns: y.columns, repeatedValue: 0.0)
    cblas_dgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans, Int32(x.rows), Int32(y.columns), Int32(x.columns), 1.0, x.grid, Int32(x.columns), y.grid, Int32(y.columns), 0.0, &(results.grid), Int32(results.columns))
    
    return results
}

public func inv(x : Matrix<Float>) -> Matrix<Float> {
    precondition(x.rows == x.columns, "Matrix must be square")
    
    var results = x
    
    var ipiv = [__CLPK_integer](count: x.rows * x.rows, repeatedValue: 0)
    var lwork = __CLPK_integer(x.columns * x.columns)
    var work = [CFloat](count: Int(lwork), repeatedValue: 0.0)
    var error: __CLPK_integer = 0
    var nc = __CLPK_integer(x.columns)
    
    sgetrf_(&nc, &nc, &(results.grid), &nc, &ipiv, &error)
    sgetri_(&nc, &(results.grid), &nc, &ipiv, &work, &lwork, &error)
    
    assert(error == 0, "Matrix not invertible")
    
    return results
}

public func inv(x : Matrix<Double>) -> Matrix<Double> {
    precondition(x.rows == x.columns, "Matrix must be square")
    
    var results = x
    
    var ipiv = [__CLPK_integer](count: x.rows * x.rows, repeatedValue: 0)
    var lwork = __CLPK_integer(x.columns * x.columns)
    var work = [CDouble](count: Int(lwork), repeatedValue: 0.0)
    var error: __CLPK_integer = 0
    var nc = __CLPK_integer(x.columns)
    
    dgetrf_(&nc, &nc, &(results.grid), &nc, &ipiv, &error)
    dgetri_(&nc, &(results.grid), &nc, &ipiv, &work, &lwork, &error)
    
    assert(error == 0, "Matrix not invertible")
    
    return results
}

public func transpose(x: Matrix<Float>) -> Matrix<Float> {
    var results = Matrix<Float>(rows: x.columns, columns: x.rows, repeatedValue: 0.0)
    vDSP_mtrans(x.grid, 1, &(results.grid), 1, vDSP_Length(results.rows), vDSP_Length(results.columns))
    
    return results
}

public func transpose(x: Matrix<Double>) -> Matrix<Double> {
    var results = Matrix<Double>(rows: x.columns, columns: x.rows, repeatedValue: 0.0)
    vDSP_mtransD(x.grid, 1, &(results.grid), 1, vDSP_Length(results.rows), vDSP_Length(results.columns))
    
    return results
}

// MARK: - Operators

public func + (lhs: Matrix<Float>, rhs: Matrix<Float>) -> Matrix<Float> {
    return add(lhs, rhs)
}

public func + (lhs: Matrix<Double>, rhs: Matrix<Double>) -> Matrix<Double> {
    return add(lhs, rhs)
}

public func * (lhs: Float, rhs: Matrix<Float>) -> Matrix<Float> {
    return mul(lhs, rhs)
}

public func * (lhs: Double, rhs: Matrix<Double>) -> Matrix<Double> {
    return mul(lhs, rhs)
}

public func * (lhs: Matrix<Float>, rhs: Matrix<Float>) -> Matrix<Float> {
    return mul(lhs, rhs)
}

public func * (lhs: Matrix<Double>, rhs: Matrix<Double>) -> Matrix<Double> {
    return mul(lhs, rhs)
}

postfix operator ′ {}
public postfix func ′ (value: Matrix<Float>) -> Matrix<Float> {
    return transpose(value)
}

public postfix func ′ (value: Matrix<Double>) -> Matrix<Double> {
    return transpose(value)
}

// MARK: Sine-Cosine

public func sincos(x: [Float]) -> (sin: [Float], cos: [Float]) {
    var sin = [Float](count: x.count, repeatedValue: 0.0)
    var cos = [Float](count: x.count, repeatedValue: 0.0)
    vvsincosf(&sin, &cos, x, [Int32(x.count)])
    
    return (sin, cos)
}

public func sincos(x: [Double]) -> (sin: [Double], cos: [Double]) {
    var sin = [Double](count: x.count, repeatedValue: 0.0)
    var cos = [Double](count: x.count, repeatedValue: 0.0)
    vvsincos(&sin, &cos, x, [Int32(x.count)])
    
    return (sin, cos)
}

// MARK: Sine

public func sin(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvsinf(&results, x, [Int32(x.count)])
    
    return results
}

public func sin(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvsin(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Cosine

public func cos(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvcosf(&results, x, [Int32(x.count)])
    
    return results
}

public func cos(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvcos(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Tangent

public func tan(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvtanf(&results, x, [Int32(x.count)])
    
    return results
}

public func tan(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvtan(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Arcsine

public func asin(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvasinf(&results, x, [Int32(x.count)])
    
    return results
}

public func asin(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvasin(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Arccosine

public func acos(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvacosf(&results, x, [Int32(x.count)])
    
    return results
}

public func acos(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvacos(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Arctangent

public func atan(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvatanf(&results, x, [Int32(x.count)])
    
    return results
}

public func atan(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvatan(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: -

// MARK: Radians to Degrees

func rad2deg(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    var divisor = [Float](count: x.count, repeatedValue: Float(M_PI / 180.0))
    vvdivf(&results, x, divisor, [Int32(x.count)])
    
    return results
}

func rad2deg(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    var divisor = [Double](count: x.count, repeatedValue: M_PI / 180.0)
    vvdiv(&results, x, divisor, [Int32(x.count)])
    
    return results
}

// MARK: Degrees to Radians

func deg2rad(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    var divisor = [Float](count: x.count, repeatedValue: Float(180.0 / M_PI))
    vvdivf(&results, x, divisor, [Int32(x.count)])
    
    return results
}

func deg2rad(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    var divisor = [Double](count: x.count, repeatedValue: 180.0 / M_PI)
    vvdiv(&results, x, divisor, [Int32(x.count)])
    
    return results
}
import Accelerate

// MARK: Sum

public func sum(x: [Float]) -> Float {
    var result: Float = 0.0
    vDSP_sve(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

public func sum(x: [Double]) -> Double {
    var result: Double = 0.0
    vDSP_sveD(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

// MARK: Sum of Absolute Values

public func asum(x: [Float]) -> Float {
    return cblas_sasum(Int32(x.count), x, 1)
}

public func asum(x: [Double]) -> Double {
    return cblas_dasum(Int32(x.count), x, 1)
}

// MARK: Maximum

public func max(x: [Float]) -> Float {
    var result: Float = 0.0
    vDSP_maxv(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

public func max(x: [Double]) -> Double {
    var result: Double = 0.0
    vDSP_maxvD(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

// MARK: Minimum

public func min(x: [Float]) -> Float {
    var result: Float = 0.0
    vDSP_minv(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

public func min(x: [Double]) -> Double {
    var result: Double = 0.0
    vDSP_minvD(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

// MARK: Mean

public func mean(x: [Float]) -> Float {
    var result: Float = 0.0
    vDSP_meanv(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

public func mean(x: [Double]) -> Double {
    var result: Double = 0.0
    vDSP_meanvD(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

// MARK: Mean Magnitude

public func meamg(x: [Float]) -> Float {
    var result: Float = 0.0
    vDSP_meamgv(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

public func meamg(x: [Double]) -> Double {
    var result: Double = 0.0
    vDSP_meamgvD(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

// MARK: Mean Square Value

public func measq(x: [Float]) -> Float {
    var result: Float = 0.0
    vDSP_measqv(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

public func measq(x: [Double]) -> Double {
    var result: Double = 0.0
    vDSP_measqvD(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

// MARK: Add

public func add(x: [Float], y: [Float]) -> [Float] {
    var results = [Float](y)
    cblas_saxpy(Int32(x.count), 1.0, x, 1, &results, 1)
    
    return results
}

public func add(x: [Double], y: [Double]) -> [Double] {
    var results = [Double](y)
    cblas_daxpy(Int32(x.count), 1.0, x, 1, &results, 1)
    
    return results
}

// MARK: Multiply

public func mul(x: [Float], y: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vDSP_vmul(x, 1, y, 1, &results, 1, vDSP_Length(x.count))
    
    return results
}

public func mul(x: [Double], y: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vDSP_vmulD(x, 1, y, 1, &results, 1, vDSP_Length(x.count))
    
    return results
}

// MARK: Divide

public func div(x: [Float], y: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvdivf(&results, x, y, [Int32(x.count)])
    
    return results
}

public func div(x: [Double], y: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvdiv(&results, x, y, [Int32(x.count)])
    
    return results
}

// MARK: Modulo

public func mod(x: [Float], y: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvfmodf(&results, x, y, [Int32(x.count)])
    
    return results
}

public func mod(x: [Double], y: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvfmod(&results, x, y, [Int32(x.count)])
    
    return results
}

// MARK: Remainder

public func remainder(x: [Float], y: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvremainderf(&results, x, y, [Int32(x.count)])
    
    return results
}

public func remainder(x: [Double], y: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvremainder(&results, x, y, [Int32(x.count)])
    
    return results
}

// MARK: Square Root

public func sqrt(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvsqrtf(&results, x, [Int32(x.count)])
    
    return results
}

public func sqrt(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvsqrt(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Dot Product

public func dot(x: [Float], y: [Float]) -> Float {
    precondition(x.count == y.count, "Vectors must have equal count")
    
    var result: Float = 0.0
    vDSP_dotpr(x, 1, y, 1, &result, vDSP_Length(x.count))
    
    return result
}


public func dot(x: [Double], y: [Double]) -> Double {
    precondition(x.count == y.count, "Vectors must have equal count")
    
    var result: Double = 0.0
    vDSP_dotprD(x, 1, y, 1, &result, vDSP_Length(x.count))
    
    return result
}

// MARK: - Operators

func + (lhs: [Float], rhs: [Float]) -> [Float] {
    return add(lhs, rhs)
}

func + (lhs: [Double], rhs: [Double]) -> [Double] {
    return add(lhs, rhs)
}

func + (lhs: [Float], rhs: Float) -> [Float] {
    return add(lhs, [Float](count: lhs.count, repeatedValue: rhs))
}

func + (lhs: [Double], rhs: Double) -> [Double] {
    return add(lhs, [Double](count: lhs.count, repeatedValue: rhs))
}

func / (lhs: [Float], rhs: [Float]) -> [Float] {
    return div(lhs, rhs)
}

func / (lhs: [Double], rhs: [Double]) -> [Double] {
    return div(lhs, rhs)
}

func / (lhs: [Float], rhs: Float) -> [Float] {
    return div(lhs, [Float](count: lhs.count, repeatedValue: rhs))
}

func / (lhs: [Double], rhs: Double) -> [Double] {
    return div(lhs, [Double](count: lhs.count, repeatedValue: rhs))
}

func * (lhs: [Float], rhs: [Float]) -> [Float] {
    return mul(lhs, rhs)
}

func * (lhs: [Double], rhs: [Double]) -> [Double] {
    return mul(lhs, rhs)
}

func * (lhs: [Float], rhs: Float) -> [Float] {
    return mul(lhs, [Float](count: lhs.count, repeatedValue: rhs))
}

func * (lhs: [Double], rhs: Double) -> [Double] {
    return mul(lhs, [Double](count: lhs.count, repeatedValue: rhs))
}

func % (lhs: [Float], rhs: [Float]) -> [Float] {
    return mod(lhs, rhs)
}

func % (lhs: [Double], rhs: [Double]) -> [Double] {
    return mod(lhs, rhs)
}

func % (lhs: [Float], rhs: Float) -> [Float] {
    return mod(lhs, [Float](count: lhs.count, repeatedValue: rhs))
}

func % (lhs: [Double], rhs: Double) -> [Double] {
    return mod(lhs, [Double](count: lhs.count, repeatedValue: rhs))
}

infix operator • {}
func • (lhs: [Double], rhs: [Double]) -> Double {
    return dot(lhs, rhs)
}

func • (lhs: [Float], rhs: [Float]) -> Float {
    return dot(lhs, rhs)
}


// MARK: Absolute Value

public func abs(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvfabs(&results, x, [Int32(x.count)])
    
    return results
}

public func abs(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvfabsf(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Ceiling

public func ceil(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvceilf(&results, x, [Int32(x.count)])
    
    return results
}

public func ceil(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvceil(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Clip

public func clip(x: [Float], low: Float, high: Float) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0), y = low, z = high
    vDSP_vclip(x, 1, &y, &z, &results, 1, vDSP_Length(x.count))
    
    return results
}

public func clip(x: [Double], low: Double, high: Double) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0), y = low, z = high
    vDSP_vclipD(x, 1, &y, &z, &results, 1, vDSP_Length(x.count))
    
    return results
}

// MARK: Copy Sign

public func copysign(sign: [Float], magnitude: [Float]) -> [Float] {
    var results = [Float](count: sign.count, repeatedValue: 0.0)
    vvcopysignf(&results, magnitude, sign, [Int32(sign.count)])
    
    return results
}

public func copysign(sign: [Double], magnitude: [Double]) -> [Double] {
    var results = [Double](count: sign.count, repeatedValue: 0.0)
    vvcopysign(&results, magnitude, sign, [Int32(sign.count)])
    
    return results
}

// MARK: Floor

public func floor(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvfloorf(&results, x, [Int32(x.count)])
    
    return results
}

public func floor(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvfloor(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Negate

public func neg(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vDSP_vneg(x, 1, &results, 1, vDSP_Length(x.count))
    
    return results
}

public func neg(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vDSP_vnegD(x, 1, &results, 1, vDSP_Length(x.count))
    
    return results
}

// MARK: Reciprocal

public func rec(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvrecf(&results, x, [Int32(x.count)])
    
    return results
}

public func rec(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvrec(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Round

public func round(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvnintf(&results, x, [Int32(x.count)])
    
    return results
}

public func round(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvnint(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Threshold

public func threshold(x: [Float], low: Float) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0), y = low
    vDSP_vthr(x, 1, &y, &results, 1, vDSP_Length(x.count))
    
    return results
}

public func threshold(x: [Double], low: Double) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0), y = low
    vDSP_vthrD(x, 1, &y, &results, 1, vDSP_Length(x.count))
    
    return results
}

// MARK: Truncate

public func trunc(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvintf(&results, x, [Int32(x.count)])
    
    return results
}

public func trunc(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvint(&results, x, [Int32(x.count)])
    
    return results
}
// MARK: Exponentiation

public func exp(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvexpf(&results, x, [Int32(x.count)])
    
    return results
}

public func exp(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvexp(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Square Exponentiation

public func exp2(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvexp2f(&results, x, [Int32(x.count)])
    
    return results
}

public func exp2(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvexp2(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Natural Logarithm

public func log(x: [Float]) -> [Float] {
    var results = [Float](x)
    vvlogf(&results, x, [Int32(x.count)])
    
    return results
}

public func log(x: [Double]) -> [Double] {
    var results = [Double](x)
    vvlog(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Base-2 Logarithm

public func log2(x: [Float]) -> [Float] {
    var results = [Float](x)
    vvlog2f(&results, x, [Int32(x.count)])
    
    return results
}

public func log2(x: [Double]) -> [Double] {
    var results = [Double](x)
    vvlog2(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Base-10 Logarithm

public func log10(x: [Float]) -> [Float] {
    var results = [Float](x)
    vvlog10f(&results, x, [Int32(x.count)])
    
    return results
}

public func log10(x: [Double]) -> [Double] {
    var results = [Double](x)
    vvlog10(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Logarithmic Exponentiation

public func logb(x: [Float]) -> [Float] {
    var results = [Float](x)
    vvlogbf(&results, x, [Int32(x.count)])
    
    return results
}

public func logb(x: [Double]) -> [Double] {
    var results = [Double](x)
    vvlogb(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Fast Fourier Transform

public func fft(input: [Float]) -> [Float] {
    var real = [Float](input)
    var imaginary = [Float](count: input.count, repeatedValue: 0.0)
    var splitComplex = DSPSplitComplex(realp: &real, imagp: &imaginary)
    
    let length = vDSP_Length(floor(log2(Float(input.count))))
    let radix = FFTRadix(kFFTRadix2)
    let weights = vDSP_create_fftsetup(length, radix)
    vDSP_fft_zip(weights, &splitComplex, 1, length, FFTDirection(FFT_FORWARD))
    
    var magnitudes = [Float](count: input.count, repeatedValue: 0.0)
    vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(input.count))
    
    var normalizedMagnitudes = [Float](count: input.count, repeatedValue: 0.0)
    vDSP_vsmul(sqrt(magnitudes), 1, [2.0 / Float(input.count)], &normalizedMagnitudes, 1, vDSP_Length(input.count))
    
    vDSP_destroy_fftsetup(weights)
    
    return normalizedMagnitudes
}

public func fft(input: [Double]) -> [Double] {
    var real = [Double](input)
    var imaginary = [Double](count: input.count, repeatedValue: 0.0)
    var splitComplex = DSPDoubleSplitComplex(realp: &real, imagp: &imaginary)
    
    let length = vDSP_Length(floor(log2(Float(input.count))))
    let radix = FFTRadix(kFFTRadix2)
    let weights = vDSP_create_fftsetupD(length, radix)
    vDSP_fft_zipD(weights, &splitComplex, 1, length, FFTDirection(FFT_FORWARD))
    
    var magnitudes = [Double](count: input.count, repeatedValue: 0.0)
    vDSP_zvmagsD(&splitComplex, 1, &magnitudes, 1, vDSP_Length(input.count))
    
    var normalizedMagnitudes = [Double](count: input.count, repeatedValue: 0.0)
    vDSP_vsmulD(sqrt(magnitudes), 1, [2.0 / Double(input.count)], &normalizedMagnitudes, 1, vDSP_Length(input.count))
    
    vDSP_destroy_fftsetupD(weights)
    
    return normalizedMagnitudes
}

// MARK: Hyperbolic Sine

public func sinh(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvsinhf(&results, x, [Int32(x.count)])
    
    return results
}

public func sinh(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvsinh(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Hyperbolic Cosine

public func cosh(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvcoshf(&results, x, [Int32(x.count)])
    
    return results
}

public func cosh(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvcosh(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Hyperbolic Tangent

public func tanh(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvtanhf(&results, x, [Int32(x.count)])
    
    return results
}

public func tanh(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvtanh(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Inverse Hyperbolic Sine

public func asinh(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvasinhf(&results, x, [Int32(x.count)])
    
    return results
}

public func asinh(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvasinh(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Inverse Hyperbolic Cosine

public func acosh(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvacoshf(&results, x, [Int32(x.count)])
    
    return results
}

public func acosh(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvacosh(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Inverse Hyperbolic Tangent

public func atanh(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvatanhf(&results, x, [Int32(x.count)])
    
    return results
}

public func atanh(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvatanh(&results, x, [Int32(x.count)])
    
    return results
}

public struct Matrix<T where T: FloatingPointType, T: FloatLiteralConvertible> {
    typealias Element = T
    
    let rows: Int
    let columns: Int
    var grid: [Element]
    
    public init(rows: Int, columns: Int, repeatedValue: Element) {
        self.rows = rows
        self.columns = columns
        
        self.grid = [Element](count: rows * columns, repeatedValue: repeatedValue)
    }
    
    public init(_ contents: [[Element]]) {
        let m: Int = contents.count
        let n: Int = contents[0].count
        let repeatedValue: Element = 0.0
        
        self.init(rows: m, columns: n, repeatedValue: repeatedValue)
        
        for (i, row) in enumerate(contents) {
            grid.replaceRange(i*n..<i*n+min(m, row.count), with: row)
        }
    }
    
    public subscript(row: Int, column: Int) -> Element {
        get {
            assert(indexIsValidForRow(row, column: column))
            return grid[(row * columns) + column]
        }
        
        set {
            assert(indexIsValidForRow(row, column: column))
            grid[(row * columns) + column] = newValue
        }
    }
    
    private func indexIsValidForRow(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
}

// MARK: - Printable

extension Matrix: Printable {
    public var description: String {
        var description = ""
        
        for i in 0..<rows {
            let contents = join("\t", map(0..<columns){"\(self[i, $0])"})
            
            switch (i, rows) {
            case (0, 1):
                description += "(\t\(contents)\t)"
            case (0, _):
                description += "⎛\t\(contents)\t⎞"
            case (rows - 1, _):
                description += "⎝\t\(contents)\t⎠"
            default:
                description += "⎜\t\(contents)\t⎥"
            }
            
            description += "\n"
        }
        
        return description
    }
}

// MARK: - SequenceType

extension Matrix: SequenceType {
    public func generate() -> GeneratorOf<ArraySlice<Element>> {
        let endIndex = rows * columns
        var nextRowStartIndex = 0
        
        return GeneratorOf<ArraySlice<Element>> {
            if nextRowStartIndex == endIndex {
                return nil
            }
            
            let currentRowStartIndex = nextRowStartIndex
            nextRowStartIndex += self.columns
            
            return self.grid[currentRowStartIndex..<nextRowStartIndex]
        }
    }
}

// MARK: -

public func add(x: Matrix<Float>, y: Matrix<Float>) -> Matrix<Float> {
    precondition(x.rows == y.rows && x.columns == y.columns, "Matrix dimensions not compatible with addition")
    
    var results = y
    cblas_saxpy(Int32(x.grid.count), 1.0, x.grid, 1, &(results.grid), 1)
    
    return results
}

public func add(x: Matrix<Double>, y: Matrix<Double>) -> Matrix<Double> {
    precondition(x.rows == y.rows && x.columns == y.columns, "Matrix dimensions not compatible with addition")
    
    var results = y
    cblas_daxpy(Int32(x.grid.count), 1.0, x.grid, 1, &(results.grid), 1)
    
    return results
}

public func mul(alpha: Float, x: Matrix<Float>) -> Matrix<Float> {
    var results = x
    cblas_sscal(Int32(x.grid.count), alpha, &(results.grid), 1)
    
    return results
}

public func mul(alpha: Double, x: Matrix<Double>) -> Matrix<Double> {
    var results = x
    cblas_dscal(Int32(x.grid.count), alpha, &(results.grid), 1)
    
    return results
}

public func mul(x: Matrix<Float>, y: Matrix<Float>) -> Matrix<Float> {
    precondition(x.columns == y.rows, "Matrix dimensions not compatible with multiplication")
    
    var results = Matrix<Float>(rows: x.rows, columns: y.columns, repeatedValue: 0.0)
    cblas_sgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans, Int32(x.rows), Int32(y.columns), Int32(x.columns), 1.0, x.grid, Int32(x.columns), y.grid, Int32(y.columns), 0.0, &(results.grid), Int32(results.columns))
    
    return results
}

public func mul(x: Matrix<Double>, y: Matrix<Double>) -> Matrix<Double> {
    precondition(x.columns == y.rows, "Matrix dimensions not compatible with multiplication")
    
    var results = Matrix<Double>(rows: x.rows, columns: y.columns, repeatedValue: 0.0)
    cblas_dgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans, Int32(x.rows), Int32(y.columns), Int32(x.columns), 1.0, x.grid, Int32(x.columns), y.grid, Int32(y.columns), 0.0, &(results.grid), Int32(results.columns))
    
    return results
}

public func inv(x : Matrix<Float>) -> Matrix<Float> {
    precondition(x.rows == x.columns, "Matrix must be square")
    
    var results = x
    
    var ipiv = [__CLPK_integer](count: x.rows * x.rows, repeatedValue: 0)
    var lwork = __CLPK_integer(x.columns * x.columns)
    var work = [CFloat](count: Int(lwork), repeatedValue: 0.0)
    var error: __CLPK_integer = 0
    var nc = __CLPK_integer(x.columns)
    
    sgetrf_(&nc, &nc, &(results.grid), &nc, &ipiv, &error)
    sgetri_(&nc, &(results.grid), &nc, &ipiv, &work, &lwork, &error)
    
    assert(error == 0, "Matrix not invertible")
    
    return results
}

public func inv(x : Matrix<Double>) -> Matrix<Double> {
    precondition(x.rows == x.columns, "Matrix must be square")
    
    var results = x
    
    var ipiv = [__CLPK_integer](count: x.rows * x.rows, repeatedValue: 0)
    var lwork = __CLPK_integer(x.columns * x.columns)
    var work = [CDouble](count: Int(lwork), repeatedValue: 0.0)
    var error: __CLPK_integer = 0
    var nc = __CLPK_integer(x.columns)
    
    dgetrf_(&nc, &nc, &(results.grid), &nc, &ipiv, &error)
    dgetri_(&nc, &(results.grid), &nc, &ipiv, &work, &lwork, &error)
    
    assert(error == 0, "Matrix not invertible")
    
    return results
}

public func transpose(x: Matrix<Float>) -> Matrix<Float> {
    var results = Matrix<Float>(rows: x.columns, columns: x.rows, repeatedValue: 0.0)
    vDSP_mtrans(x.grid, 1, &(results.grid), 1, vDSP_Length(results.rows), vDSP_Length(results.columns))
    
    return results
}

public func transpose(x: Matrix<Double>) -> Matrix<Double> {
    var results = Matrix<Double>(rows: x.columns, columns: x.rows, repeatedValue: 0.0)
    vDSP_mtransD(x.grid, 1, &(results.grid), 1, vDSP_Length(results.rows), vDSP_Length(results.columns))
    
    return results
}

// MARK: - Operators

public func + (lhs: Matrix<Float>, rhs: Matrix<Float>) -> Matrix<Float> {
    return add(lhs, rhs)
}

public func + (lhs: Matrix<Double>, rhs: Matrix<Double>) -> Matrix<Double> {
    return add(lhs, rhs)
}

public func * (lhs: Float, rhs: Matrix<Float>) -> Matrix<Float> {
    return mul(lhs, rhs)
}

public func * (lhs: Double, rhs: Matrix<Double>) -> Matrix<Double> {
    return mul(lhs, rhs)
}

public func * (lhs: Matrix<Float>, rhs: Matrix<Float>) -> Matrix<Float> {
    return mul(lhs, rhs)
}

public func * (lhs: Matrix<Double>, rhs: Matrix<Double>) -> Matrix<Double> {
    return mul(lhs, rhs)
}

postfix operator ′ {}
public postfix func ′ (value: Matrix<Float>) -> Matrix<Float> {
    return transpose(value)
}

public postfix func ′ (value: Matrix<Double>) -> Matrix<Double> {
    return transpose(value)
}

// MARK: Sine-Cosine

public func sincos(x: [Float]) -> (sin: [Float], cos: [Float]) {
    var sin = [Float](count: x.count, repeatedValue: 0.0)
    var cos = [Float](count: x.count, repeatedValue: 0.0)
    vvsincosf(&sin, &cos, x, [Int32(x.count)])
    
    return (sin, cos)
}

public func sincos(x: [Double]) -> (sin: [Double], cos: [Double]) {
    var sin = [Double](count: x.count, repeatedValue: 0.0)
    var cos = [Double](count: x.count, repeatedValue: 0.0)
    vvsincos(&sin, &cos, x, [Int32(x.count)])
    
    return (sin, cos)
}

// MARK: Sine

public func sin(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvsinf(&results, x, [Int32(x.count)])
    
    return results
}

public func sin(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvsin(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Cosine

public func cos(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvcosf(&results, x, [Int32(x.count)])
    
    return results
}

public func cos(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvcos(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Tangent

public func tan(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvtanf(&results, x, [Int32(x.count)])
    
    return results
}

public func tan(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvtan(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Arcsine

public func asin(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvasinf(&results, x, [Int32(x.count)])
    
    return results
}

public func asin(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvasin(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Arccosine

public func acos(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvacosf(&results, x, [Int32(x.count)])
    
    return results
}

public func acos(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvacos(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Arctangent

public func atan(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvatanf(&results, x, [Int32(x.count)])
    
    return results
}

public func atan(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvatan(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: -

// MARK: Radians to Degrees

func rad2deg(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    var divisor = [Float](count: x.count, repeatedValue: Float(M_PI / 180.0))
    vvdivf(&results, x, divisor, [Int32(x.count)])
    
    return results
}

func rad2deg(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    var divisor = [Double](count: x.count, repeatedValue: M_PI / 180.0)
    vvdiv(&results, x, divisor, [Int32(x.count)])
    
    return results
}

// MARK: Degrees to Radians

func deg2rad(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    var divisor = [Float](count: x.count, repeatedValue: Float(180.0 / M_PI))
    vvdivf(&results, x, divisor, [Int32(x.count)])
    
    return results
}

func deg2rad(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    var divisor = [Double](count: x.count, repeatedValue: 180.0 / M_PI)
    vvdiv(&results, x, divisor, [Int32(x.count)])
    
    return results
}
import Accelerate

// MARK: Sum

public func sum(x: [Float]) -> Float {
    var result: Float = 0.0
    vDSP_sve(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

public func sum(x: [Double]) -> Double {
    var result: Double = 0.0
    vDSP_sveD(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

// MARK: Sum of Absolute Values

public func asum(x: [Float]) -> Float {
    return cblas_sasum(Int32(x.count), x, 1)
}

public func asum(x: [Double]) -> Double {
    return cblas_dasum(Int32(x.count), x, 1)
}

// MARK: Maximum

public func max(x: [Float]) -> Float {
    var result: Float = 0.0
    vDSP_maxv(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

public func max(x: [Double]) -> Double {
    var result: Double = 0.0
    vDSP_maxvD(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

// MARK: Minimum

public func min(x: [Float]) -> Float {
    var result: Float = 0.0
    vDSP_minv(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

public func min(x: [Double]) -> Double {
    var result: Double = 0.0
    vDSP_minvD(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

// MARK: Mean

public func mean(x: [Float]) -> Float {
    var result: Float = 0.0
    vDSP_meanv(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

public func mean(x: [Double]) -> Double {
    var result: Double = 0.0
    vDSP_meanvD(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

// MARK: Mean Magnitude

public func meamg(x: [Float]) -> Float {
    var result: Float = 0.0
    vDSP_meamgv(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

public func meamg(x: [Double]) -> Double {
    var result: Double = 0.0
    vDSP_meamgvD(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

// MARK: Mean Square Value

public func measq(x: [Float]) -> Float {
    var result: Float = 0.0
    vDSP_measqv(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

public func measq(x: [Double]) -> Double {
    var result: Double = 0.0
    vDSP_measqvD(x, 1, &result, vDSP_Length(x.count))
    
    return result
}

// MARK: Add

public func add(x: [Float], y: [Float]) -> [Float] {
    var results = [Float](y)
    cblas_saxpy(Int32(x.count), 1.0, x, 1, &results, 1)
    
    return results
}

public func add(x: [Double], y: [Double]) -> [Double] {
    var results = [Double](y)
    cblas_daxpy(Int32(x.count), 1.0, x, 1, &results, 1)
    
    return results
}

// MARK: Multiply

public func mul(x: [Float], y: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vDSP_vmul(x, 1, y, 1, &results, 1, vDSP_Length(x.count))
    
    return results
}

public func mul(x: [Double], y: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vDSP_vmulD(x, 1, y, 1, &results, 1, vDSP_Length(x.count))
    
    return results
}

// MARK: Divide

public func div(x: [Float], y: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvdivf(&results, x, y, [Int32(x.count)])
    
    return results
}

public func div(x: [Double], y: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvdiv(&results, x, y, [Int32(x.count)])
    
    return results
}

// MARK: Modulo

public func mod(x: [Float], y: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvfmodf(&results, x, y, [Int32(x.count)])
    
    return results
}

public func mod(x: [Double], y: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvfmod(&results, x, y, [Int32(x.count)])
    
    return results
}

// MARK: Remainder

public func remainder(x: [Float], y: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvremainderf(&results, x, y, [Int32(x.count)])
    
    return results
}

public func remainder(x: [Double], y: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvremainder(&results, x, y, [Int32(x.count)])
    
    return results
}

// MARK: Square Root

public func sqrt(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvsqrtf(&results, x, [Int32(x.count)])
    
    return results
}

public func sqrt(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvsqrt(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Dot Product

public func dot(x: [Float], y: [Float]) -> Float {
    precondition(x.count == y.count, "Vectors must have equal count")
    
    var result: Float = 0.0
    vDSP_dotpr(x, 1, y, 1, &result, vDSP_Length(x.count))
    
    return result
}


public func dot(x: [Double], y: [Double]) -> Double {
    precondition(x.count == y.count, "Vectors must have equal count")
    
    var result: Double = 0.0
    vDSP_dotprD(x, 1, y, 1, &result, vDSP_Length(x.count))
    
    return result
}

// MARK: - Operators

func + (lhs: [Float], rhs: [Float]) -> [Float] {
    return add(lhs, rhs)
}

func + (lhs: [Double], rhs: [Double]) -> [Double] {
    return add(lhs, rhs)
}

func + (lhs: [Float], rhs: Float) -> [Float] {
    return add(lhs, [Float](count: lhs.count, repeatedValue: rhs))
}

func + (lhs: [Double], rhs: Double) -> [Double] {
    return add(lhs, [Double](count: lhs.count, repeatedValue: rhs))
}

func / (lhs: [Float], rhs: [Float]) -> [Float] {
    return div(lhs, rhs)
}

func / (lhs: [Double], rhs: [Double]) -> [Double] {
    return div(lhs, rhs)
}

func / (lhs: [Float], rhs: Float) -> [Float] {
    return div(lhs, [Float](count: lhs.count, repeatedValue: rhs))
}

func / (lhs: [Double], rhs: Double) -> [Double] {
    return div(lhs, [Double](count: lhs.count, repeatedValue: rhs))
}

func * (lhs: [Float], rhs: [Float]) -> [Float] {
    return mul(lhs, rhs)
}

func * (lhs: [Double], rhs: [Double]) -> [Double] {
    return mul(lhs, rhs)
}

func * (lhs: [Float], rhs: Float) -> [Float] {
    return mul(lhs, [Float](count: lhs.count, repeatedValue: rhs))
}

func * (lhs: [Double], rhs: Double) -> [Double] {
    return mul(lhs, [Double](count: lhs.count, repeatedValue: rhs))
}

func % (lhs: [Float], rhs: [Float]) -> [Float] {
    return mod(lhs, rhs)
}

func % (lhs: [Double], rhs: [Double]) -> [Double] {
    return mod(lhs, rhs)
}

func % (lhs: [Float], rhs: Float) -> [Float] {
    return mod(lhs, [Float](count: lhs.count, repeatedValue: rhs))
}

func % (lhs: [Double], rhs: Double) -> [Double] {
    return mod(lhs, [Double](count: lhs.count, repeatedValue: rhs))
}

infix operator • {}
func • (lhs: [Double], rhs: [Double]) -> Double {
    return dot(lhs, rhs)
}

func • (lhs: [Float], rhs: [Float]) -> Float {
    return dot(lhs, rhs)
}


// MARK: Absolute Value

public func abs(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvfabs(&results, x, [Int32(x.count)])
    
    return results
}

public func abs(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvfabsf(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Ceiling

public func ceil(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvceilf(&results, x, [Int32(x.count)])
    
    return results
}

public func ceil(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvceil(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Clip

public func clip(x: [Float], low: Float, high: Float) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0), y = low, z = high
    vDSP_vclip(x, 1, &y, &z, &results, 1, vDSP_Length(x.count))
    
    return results
}

public func clip(x: [Double], low: Double, high: Double) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0), y = low, z = high
    vDSP_vclipD(x, 1, &y, &z, &results, 1, vDSP_Length(x.count))
    
    return results
}

// MARK: Copy Sign

public func copysign(sign: [Float], magnitude: [Float]) -> [Float] {
    var results = [Float](count: sign.count, repeatedValue: 0.0)
    vvcopysignf(&results, magnitude, sign, [Int32(sign.count)])
    
    return results
}

public func copysign(sign: [Double], magnitude: [Double]) -> [Double] {
    var results = [Double](count: sign.count, repeatedValue: 0.0)
    vvcopysign(&results, magnitude, sign, [Int32(sign.count)])
    
    return results
}

// MARK: Floor

public func floor(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvfloorf(&results, x, [Int32(x.count)])
    
    return results
}

public func floor(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvfloor(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Negate

public func neg(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vDSP_vneg(x, 1, &results, 1, vDSP_Length(x.count))
    
    return results
}

public func neg(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vDSP_vnegD(x, 1, &results, 1, vDSP_Length(x.count))
    
    return results
}

// MARK: Reciprocal

public func rec(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvrecf(&results, x, [Int32(x.count)])
    
    return results
}

public func rec(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvrec(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Round

public func round(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvnintf(&results, x, [Int32(x.count)])
    
    return results
}

public func round(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvnint(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Threshold

public func threshold(x: [Float], low: Float) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0), y = low
    vDSP_vthr(x, 1, &y, &results, 1, vDSP_Length(x.count))
    
    return results
}

public func threshold(x: [Double], low: Double) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0), y = low
    vDSP_vthrD(x, 1, &y, &results, 1, vDSP_Length(x.count))
    
    return results
}

// MARK: Truncate

public func trunc(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvintf(&results, x, [Int32(x.count)])
    
    return results
}

public func trunc(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvint(&results, x, [Int32(x.count)])
    
    return results
}
// MARK: Exponentiation

public func exp(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvexpf(&results, x, [Int32(x.count)])
    
    return results
}

public func exp(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvexp(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Square Exponentiation

public func exp2(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvexp2f(&results, x, [Int32(x.count)])
    
    return results
}

public func exp2(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvexp2(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Natural Logarithm

public func log(x: [Float]) -> [Float] {
    var results = [Float](x)
    vvlogf(&results, x, [Int32(x.count)])
    
    return results
}

public func log(x: [Double]) -> [Double] {
    var results = [Double](x)
    vvlog(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Base-2 Logarithm

public func log2(x: [Float]) -> [Float] {
    var results = [Float](x)
    vvlog2f(&results, x, [Int32(x.count)])
    
    return results
}

public func log2(x: [Double]) -> [Double] {
    var results = [Double](x)
    vvlog2(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Base-10 Logarithm

public func log10(x: [Float]) -> [Float] {
    var results = [Float](x)
    vvlog10f(&results, x, [Int32(x.count)])
    
    return results
}

public func log10(x: [Double]) -> [Double] {
    var results = [Double](x)
    vvlog10(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Logarithmic Exponentiation

public func logb(x: [Float]) -> [Float] {
    var results = [Float](x)
    vvlogbf(&results, x, [Int32(x.count)])
    
    return results
}

public func logb(x: [Double]) -> [Double] {
    var results = [Double](x)
    vvlogb(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Fast Fourier Transform

public func fft(input: [Float]) -> [Float] {
    var real = [Float](input)
    var imaginary = [Float](count: input.count, repeatedValue: 0.0)
    var splitComplex = DSPSplitComplex(realp: &real, imagp: &imaginary)
    
    let length = vDSP_Length(floor(log2(Float(input.count))))
    let radix = FFTRadix(kFFTRadix2)
    let weights = vDSP_create_fftsetup(length, radix)
    vDSP_fft_zip(weights, &splitComplex, 1, length, FFTDirection(FFT_FORWARD))
    
    var magnitudes = [Float](count: input.count, repeatedValue: 0.0)
    vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(input.count))
    
    var normalizedMagnitudes = [Float](count: input.count, repeatedValue: 0.0)
    vDSP_vsmul(sqrt(magnitudes), 1, [2.0 / Float(input.count)], &normalizedMagnitudes, 1, vDSP_Length(input.count))
    
    vDSP_destroy_fftsetup(weights)
    
    return normalizedMagnitudes
}

public func fft(input: [Double]) -> [Double] {
    var real = [Double](input)
    var imaginary = [Double](count: input.count, repeatedValue: 0.0)
    var splitComplex = DSPDoubleSplitComplex(realp: &real, imagp: &imaginary)
    
    let length = vDSP_Length(floor(log2(Float(input.count))))
    let radix = FFTRadix(kFFTRadix2)
    let weights = vDSP_create_fftsetupD(length, radix)
    vDSP_fft_zipD(weights, &splitComplex, 1, length, FFTDirection(FFT_FORWARD))
    
    var magnitudes = [Double](count: input.count, repeatedValue: 0.0)
    vDSP_zvmagsD(&splitComplex, 1, &magnitudes, 1, vDSP_Length(input.count))
    
    var normalizedMagnitudes = [Double](count: input.count, repeatedValue: 0.0)
    vDSP_vsmulD(sqrt(magnitudes), 1, [2.0 / Double(input.count)], &normalizedMagnitudes, 1, vDSP_Length(input.count))
    
    vDSP_destroy_fftsetupD(weights)
    
    return normalizedMagnitudes
}

// MARK: Hyperbolic Sine

public func sinh(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvsinhf(&results, x, [Int32(x.count)])
    
    return results
}

public func sinh(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvsinh(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Hyperbolic Cosine

public func cosh(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvcoshf(&results, x, [Int32(x.count)])
    
    return results
}

public func cosh(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvcosh(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Hyperbolic Tangent

public func tanh(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvtanhf(&results, x, [Int32(x.count)])
    
    return results
}

public func tanh(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvtanh(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Inverse Hyperbolic Sine

public func asinh(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvasinhf(&results, x, [Int32(x.count)])
    
    return results
}

public func asinh(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvasinh(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Inverse Hyperbolic Cosine

public func acosh(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvacoshf(&results, x, [Int32(x.count)])
    
    return results
}

public func acosh(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvacosh(&results, x, [Int32(x.count)])
    
    return results
}

// MARK: Inverse Hyperbolic Tangent

public func atanh(x: [Float]) -> [Float] {
    var results = [Float](count: x.count, repeatedValue: 0.0)
    vvatanhf(&results, x, [Int32(x.count)])
    
    return results
}

public func atanh(x: [Double]) -> [Double] {
    var results = [Double](count: x.count, repeatedValue: 0.0)
    vvatanh(&results, x, [Int32(x.count)])
    
    return results
}

public struct Matrix<T where T: FloatingPointType, T: FloatLiteralConvertible> {
    typealias Element = T
    
    let rows: Int
    let columns: Int
    var grid: [Element]
    
    public init(rows: Int, columns: Int, repeatedValue: Element) {
        self.rows = rows
        self.columns = columns
        
        self.grid = [Element](count: rows * columns, repeatedValue: repeatedValue)
    }
    
    public init(_ contents: [[Element]]) {
        let m: Int = contents.count
        let n: Int = contents[0].count
        let repeatedValue: Element = 0.0
        
        self.init(rows: m, columns: n, repeatedValue: repeatedValue)
        
        for (i, row) in enumerate(contents) {
            grid.replaceRange(i*n..<i*n+min(m, row.count), with: row)
        }
    }
    
    public subscript(row: Int, column: Int) -> Element {
        get {
            assert(indexIsValidForRow(row, column: column))
            return grid[(row * columns) + column]
        }
        
        set {
            assert(indexIsValidForRow(row, column: column))
            grid[(row * columns) + column] = newValue
        }
    }
    
    private func indexIsValidForRow(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
}

// MARK: - Printable

extension Matrix: Printable {
    public var description: String {
        var description = ""
        
        for i in 0..<rows {
            let contents = join("\t", map(0..<columns){"\(self[i, $0])"})
            
            switch (i, rows) {
            case (0, 1):
                description += "(\t\(contents)\t)"
            case (0, _):
                description += "⎛\t\(contents)\t⎞"
            case (rows - 1, _):
                description += "⎝\t\(contents)\t⎠"
            default:
                description += "⎜\t\(contents)\t⎥"
            }
            
            description += "\n"
        }
        
        return description
    }
}

// MARK: - SequenceType

extension Matrix: SequenceType {
    public func generate() -> GeneratorOf<ArraySlice<Element>> {
        let endIndex = rows * columns
        var nextRowStartIndex = 0
        
        return GeneratorOf<ArraySlice<Element>> {
            if nextRowStartIndex == endIndex {
                return nil
            }
            
            let currentRowStartIndex = nextRowStartIndex
            nextRowStartIndex += self.columns
            
            return self.grid[currentRowStartIndex..<nextRowStartIndex]
        }
    }
}

// MARK: -

public func add(x: Matrix<Float>, y: Matrix<Float>) -> Matrix<Float> {
    precondition(x.rows == y.rows && x.columns == y.columns, "Matrix dimensions not compatible with addition")
    
    var results = y
    cblas_saxpy(Int32(x.grid.count), 1.0, x.grid, 1, &(results.grid), 1)
    
    return results
}

public func add(x: Matrix<Double>, y: Matrix<Double>) -> Matrix<Double> {
    precondition(x.rows == y.rows && x.columns == y.columns, "Matrix dimensions not compatible with addition")
    
    var results = y
    cblas_daxpy(Int32(x.grid.count), 1.0, x.grid, 1, &(results.grid), 1)
    
    return results
}

public func mul(alpha: Float, x: Matrix<Float>) -> Matrix<Float> {
    var results = x
    cblas_sscal(Int32(x.grid.count), alpha, &(results.grid), 1)
    
    return results
}

public func mul(alpha: Double, x: Matrix<Double>) -> Matrix<Double> {
    var results = x
    cblas_dscal(Int32(x.grid.count), alpha, &(results.grid), 1)
    
    return results
}

public func mul(x: Matrix<Float>, y: Matrix<Float>) -> Matrix<Float> {
    precondition(x.columns == y.rows, "Matrix dimensions not compatible with multiplication")
    
    var results = Matrix<Float>(rows: x.rows, columns: y.columns, repeatedValue: 0.0)
    cblas_sgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans, Int32(x.rows), Int32(y.columns), Int32(x.columns), 1.0, x.grid, Int32(x.columns), y.grid, Int32(y.columns), 0.0, &(results.grid), Int32(results.columns))
    
    return results
}

public func mul(x: Matrix<Double>, y: Matrix<Double>) -> Matrix<Double> {
    precondition(x.columns == y.rows, "Matrix dimensions not compatible with multiplication")
    
    var results = Matrix<Double>(rows: x.rows, columns: y.columns, repeatedValue: 0.0)
    cblas_dgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans, Int32(x.rows), Int32(y.columns), Int32(x.columns), 1.0, x.grid, Int32(x.columns), y.grid, Int32(y.columns), 0.0, &(results.grid), Int32(results.columns))
    
    return results
}

public func inv(x : Matrix<Float>) -> Matrix<Float> {
    precondition(x.rows == x.columns, "Matrix must be square")
    
    var results = x
    
    var ipiv = [__CLPK_integer](count: x.rows * x.rows, repeatedValue: 0)
    var lwork = __CLPK_integer(x.columns * x.columns)
    var work = [CFloat](count: Int(lwork), repeatedValue: 0.0)
    var error: __CLPK_integer = 0
    var nc = __CLPK_integer(x.columns)
    
    sgetrf_(&nc, &nc, &(results.grid), &nc, &ipiv, &error)
    sgetri_(&nc, &(results.grid), &nc, &ipiv, &work, &lwork, &error)
    
    assert(error == 0, "Matrix not invertible")
    
    return results
}